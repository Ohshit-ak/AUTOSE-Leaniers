"""Lean documentation lookup for repair feedback (v11, issue 6).

When Lean rejects a name the model invented (`List.last`), a type it got wrong (`List.head`
needs a proof) or an instance that does not exist (`Membership String String`), the repair
feedback quotes the real Lean entries: signature + the first sentence of the docstring.

Source: the Lean environment the specs are checked against (Lean 4.29.1 + ContractForge, no
Mathlib), read once with `findDocString?` and cached next to `core_names`
(`framework/.lake/cf_core_docs.json`). Deterministic; at most MAX_ENTRIES entries per error.
"""
import json
import os
import re
import subprocess
import tempfile
from typing import Dict, List, Optional

from config import FRAMEWORK_PATH
from lean_runner import NAME_SPACES

MAX_ENTRIES = 3
_CACHE = FRAMEWORK_PATH / ".lake" / "cf_core_docs.json"
_SCRIPT = """import Lean
import ContractForge
open Lean Meta

#eval show MetaM Unit from do
  let env ← getEnv
  let spaces : List Name := [%s]
  for (n, ci) in env.constants.toList do
    if n.isInternal || isPrivateName n then continue
    let some idx := env.getModuleIdxFor? n | continue
    unless (env.header.moduleNames[idx.toNat]!).getRoot == `Init do continue
    if ci matches .thmInfo _ then continue
    match n with
    | .str p s =>
      if spaces.contains p && !s.startsWith "_" && !s.startsWith "inst" then
        let ty ← ppExpr ci.type
        let doc ← findDocString? env n
        IO.println (Json.compress (Json.mkObj [("n", toJson n.toString), ("t", toJson (toString ty)),
                                               ("d", toJson (doc.getD ""))]))
    | _ => pure ()
"""
_index: Optional[Dict[str, dict]] = None


def build_index() -> Dict[str, dict]:
    """{full name: {"t": signature, "d": docstring}} from Lean (about 20 s), cached."""
    script = _SCRIPT % ", ".join(f"`{n}" for n in NAME_SPACES)
    with tempfile.NamedTemporaryFile(suffix=".lean", mode="w", encoding="utf-8", delete=False) as f:
        f.write(script)
        path = f.name
    try:
        out = subprocess.run(["lake", "env", "lean", path], capture_output=True, text=True,
                             encoding="utf-8", errors="replace", timeout=600, cwd=FRAMEWORK_PATH).stdout
    finally:
        os.unlink(path)
    index = {}
    for line in out.splitlines():
        if line.startswith("{"):
            try:
                e = json.loads(line)
            except ValueError:
                continue
            index[e["n"]] = {"t": e["t"], "d": e["d"]}
    if index:
        _CACHE.parent.mkdir(parents=True, exist_ok=True)
        _CACHE.write_text(json.dumps({"spaces": NAME_SPACES, "entries": index}), encoding="utf-8")
    return index


def index() -> Dict[str, dict]:
    global _index
    if _index is None:
        if _CACHE.exists():
            cached = json.loads(_CACHE.read_text(encoding="utf-8"))
            if cached.get("spaces") == NAME_SPACES:
                _index = cached["entries"]
        if _index is None:
            try:
                _index = build_index()
            except (OSError, subprocess.SubprocessError):
                _index = {}
    return _index


# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------

def _drop_binders(sig: str) -> str:
    """`{α : Type u} → [BEq α] → List α → Bool` → `List α → Bool` (implicit and instance binders)."""
    sig = " ".join(sig.split())
    while sig[:1] in "{[⦃":
        close = {"{": "}", "[": "]", "⦃": "⦄"}[sig[0]]
        depth = 0
        for k, c in enumerate(sig):
            depth += c == sig[0]
            depth -= c == close
            if depth == 0:
                break
        rest = sig[k + 1:].lstrip()
        if not rest.startswith("→"):
            break
        sig = rest[1:].lstrip()
    return sig


def _unescape(doc: str) -> str:
    return re.sub(r"\\([\\.()\[\]{}*_#!`-])", r"\1", doc)


def _first_sentence(doc: str) -> str:
    doc = " ".join(_unescape(doc).split())
    m = re.match(r"(.+?[.!?])(\s|$)", doc)
    s = m.group(1) if m else doc
    return s if len(s) <= 160 else s[:157] + "…"


def _example(doc: str) -> str:
    m = re.search(r"\*\s*`([^`\n]{3,80})`", _unescape(doc))
    return m.group(1) if m else ""


def entry_line(name: str) -> str:
    e = index().get(name)
    if e is None:
        return ""
    line = f"- `{name} : {_drop_binders(e['t'])}`"
    sent = _first_sentence(e["d"]) if e["d"] else ""
    ex = _example(e["d"]) if e["d"] else ""
    if sent:
        line += f" -- {sent}"
    if ex:
        line += f" e.g. `{ex}`"
    return line


# ---------------------------------------------------------------------------
# Retrieval
# ---------------------------------------------------------------------------

def _space(owner: str) -> str:
    owner = owner.split(".")[-1]
    return owner[:1].upper() + owner[1:]


def closest(owner: str, name: str, n: int = MAX_ENTRIES) -> List[str]:
    """The real names in `owner`'s namespace closest to `owner.name`. Names that contain the
    invented one come first, the total versions (`getLast?`, `getLastD`) before the partial ones;
    then edit distance."""
    from agents.repair import closest as near
    space = _space(owner)
    pref = space + "."
    short = [k[len(pref):] for k in index() if k.startswith(pref) and "." not in k[len(pref):]]
    key = name.rstrip("?!").lower()
    contains = sorted((c for c in short if key and key in c.lower()),
                      key=lambda c: (not c.endswith(("?", "D")), c.endswith("!"), len(c), c))
    rest = [c for c in near(name, short, n) if c not in contains]
    return [pref + c for c in (contains + rest)[:n]]


def _variants(space: str, name: str) -> List[str]:
    """`space.name` and its safe siblings (`name?`, `nameD`, `name!`) that exist."""
    base = name.rstrip("?!")
    out = []
    for cand in (base + "?", base + "D", base, base + "!"):
        full = f"{space}.{cand}"
        if full in index() and full not in out:
            out.append(full)
    return out


# Class → names of functions that do the job when the instance is missing (Lean core knowledge,
# independent of any SRS): `x ∈ s` on a String is `s.contains x`, `a \ b` on lists is `removeAll`.
CLASS_FUNCS = {
    "Membership": ["contains", "elem", "any", "isPrefixOf", "isInfixOf"],
    "SDiff": ["removeAll", "erase", "filter", "diff"],
    "HAppend": ["append", "push", "concat"],
    "HAdd": ["append", "push"],
    "LE": ["le", "decLe", "lt"],
    "LT": ["lt", "decLt", "le"],
    "Max": ["max", "maximum?"],
    "Min": ["min", "minimum?"],
    "HDiv": ["div"],
    "OfNat": ["ofNat"],
    "ToString": ["toString", "repr"],
}
_SYNTH = re.compile(r"failed to synthesize(?: instance of type class)?\s*\n?\s*(\w+)\s+(.+)")


def _type_heads(text: str) -> List[str]:
    return [s for s in NAME_SPACES if re.search(rf"(?<![\w.]){s}\b", text)]


def lookup(msg: str, line: str = "") -> List[str]:
    """Up to MAX_ENTRIES formatted entries for one Lean error message (`line`: the code line
    the error is on, used to find the function a type error is about)."""
    if not index():
        return []
    names: List[str] = []
    # 1. a name that does not exist → the closest real ones
    m = (re.search(r"does not contain `([\w.]+)\.([\w?!']+)`", msg)
         or re.search(r"[Uu]nknown (?:identifier|constant) `([\w.]+)\.([\w?!']+)`", msg))
    if m:
        owner, name = m.group(1), m.group(2)
        space = _space(owner)
        if space == "Function":   # `.name` projected from a function value: meant for the list
            space = "List"
        if space in NAME_SPACES:
            # `maxOption` → `max?`: the leading word of a camelCase name, then near names
            head = re.match(r"[a-z]+", name)
            names = (_variants(space, name)
                     + (_variants(space, head.group(0)) if head and head.group(0) != name else [])
                     + closest(space, name))
            if space == "String" and not names:   # list functions apply after `.toList`
                names = _variants("List", name) + closest("List", name)
    # 2. a missing instance → functions of the type that do the job
    elif "failed to synthesize" in msg:
        s = _SYNTH.search(msg)
        if s and s.group(1) in CLASS_FUNCS:
            heads = _type_heads(s.group(2)) or ["List"]
            want = CLASS_FUNCS[s.group(1)]
            for h in reversed(heads):          # the container type is usually the last argument
                names += [f"{h}.{w}" for w in want if f"{h}.{w}" in index()]
    # 3. a type error about a function → its real signature (and safe variants)
    elif re.search(r"[Tt]ype mismatch|Function expected|Invalid argument", msg):
        text = msg + "\n" + line
        heads = list(dict.fromkeys(_type_heads(text) + ["List", "String", "Option"]))
        # the last projection of a term (`xs.toList.head`) is the one the error is about
        lines = [x.strip() for x in msg.splitlines()[1:] if x.strip()]
        term = lines[0] if lines else ""
        proj = lambda t: re.findall(r"\.([a-z][\w?!]*)", t)  # noqa: E731
        for w in dict.fromkeys(list(reversed(proj(term))) + list(reversed(proj(line))) + proj(msg)):
            for h in heads:
                names += _variants(h, w)
    out = []
    for n in dict.fromkeys(names):
        e = entry_line(n)
        if e:
            out.append(e)
        if len(out) == MAX_ENTRIES:
            break
    return out
