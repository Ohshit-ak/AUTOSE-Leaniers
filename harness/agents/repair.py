"""Turn Lean's raw output into short, targeted repair feedback for the model.

Lean's output is long and its positions refer to the checked file (header +
locked context + code). This keeps the first few errors, maps each position to
a line of the model's own code, trims long type dumps, and adds a one-line hint
chosen by the kind of error.
"""
import re
from typing import List, Optional

from config import FRAMEWORK_PATH
from lean_runner import HEADER, core_names

MAX_ERRORS = 3          # errors shown per repair
MAX_MSG_LINES = 8       # lines kept per error message
MAX_MSG_CHARS = 600     # characters kept per error message

_ERROR = re.compile(r"^<generated>:(\d+):(\d+): error(?:\([^)]*\))?: ?(.*)$")
_DIAG = re.compile(r"^<generated>:\d+:\d+: (?:error|warning|info)")
_STRUCT = re.compile(r"^structure\s+(\w+)[^\n]*\bwhere\s*\n((?:[ \t]+.*\n?)*)", re.MULTILINE)
_FIELD = re.compile(r"^[ \t]+(\w+)\s*:", re.MULTILINE)

KEYWORDS = "exists, fun, end, at, from, have, show, do, let, in, then, else, match, with, where, by"

# Lean 3 names models keep writing; Lean 4 spells them differently.
LEAN3_NAMES = {
    "dec_trivial": "`by decide`",
    "and.intro": "`⟨h₁, h₂⟩` (or `And.intro`)",
    "or.inl": "`Or.inl`",
    "or.inr": "`Or.inr`",
    "nat.succ": "`Nat.succ`",
    "list.length": "`List.length`",
}


def edit_distance(a: str, b: str) -> int:
    """Levenshtein distance, ignoring case."""
    a, b = a.lower(), b.lower()
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return prev[-1]


def closest(name: str, candidates, n: int = 3) -> List[str]:
    """The `n` candidates nearest to `name` by edit distance (ties: shorter, then alphabetical).
    A candidate containing `name` (or contained in it) counts as distance 1."""
    def key(c: str):
        d = edit_distance(name, c)
        if name.lower() in c.lower() or c.lower() in name.lower():
            d = min(d, 1)
        return (d, len(c), c)
    uniq = sorted(set(candidates), key=key)
    limit = max(2, len(name) // 2)  # farther than this is not a plausible typo or synonym
    return [c for c in uniq if key(c)[0] <= limit][:n]


_HELPER_DEF = re.compile(r"^def\s+(\w+)", re.MULTILINE)


def framework_helpers() -> List[str]:
    """Top-level helpers the framework provides to specs (e.g. `allDigits`)."""
    names = []
    for f in sorted((FRAMEWORK_PATH / "ContractForge").glob("*.lean")):
        names += _HELPER_DEF.findall(f.read_text(encoding="utf-8"))
    return names


def local_names(code: str) -> List[str]:
    """Structures and defs declared in the model's code."""
    return re.findall(r"^(?:structure|def|abbrev|inductive)\s+(\w+)", code, re.MULTILINE)


def suggest_names(owner: str, name: str) -> List[str]:
    """The 3 real Lean core names in `owner`'s namespace closest to the invented `owner.name`
    (edit distance), e.g. Char.isAlphabetic → Char.isAlpha. For `String`, functions reached
    through `.toList` count too."""
    names = core_names()
    space = owner[:1].upper() + owner[1:]  # Lean 3 used lowercase namespaces (nat, list)
    cands = [f"{space}.{c}" for c in names.get(space, [])]
    if space == "String":
        cands += [f"s.toList.{c}" for c in names.get("List", [])]
    by_short = {c.rsplit(".", 1)[-1]: c for c in reversed(cands)}
    return [by_short[c] for c in closest(name, list(by_short))]


def structure_fields(code: str) -> dict:
    """{structure name: [field names]} for the structures defined in `code`."""
    return {m.group(1): _FIELD.findall(m.group(2)) for m in _STRUCT.finditer(code)}


def contains_itself(code: str, name: str) -> bool:
    """True if `structure name` has a field whose type mentions `name` (e.g. `List Category`)."""
    for m in _STRUCT.finditer(code):
        if m.group(1) == name:
            types = re.findall(r"^[ \t]+\w+\s*:\s*(.+)$", m.group(2), re.MULTILINE)
            return any(re.search(rf"\b{re.escape(name)}\b", t) for t in types)
    return False


def _uses(code: str, name: str) -> str:
    """'lines 12, 15' — where `<x>.name` appears in `code`."""
    lines = [str(k) for k, ln in enumerate(code.splitlines(), 1)
             if re.search(rf"\.{re.escape(name)}\b|\b{re.escape(name)}\s*:=", ln)]
    return f"line{'s' * (len(lines) > 1)} {', '.join(lines[:4])}" if lines else "the code"


def undeclared_field_hint(fields: dict, struct: str, name: str, code: str) -> str:
    """A field used but not declared: name it, say where it is used, list the closest
    declared fields, and ask for a declaration. The harness never inserts it itself."""
    have = fields.get(struct, [])
    near = closest(name, have)
    alt = f" If you meant an existing field: {', '.join(f'`{f}`' for f in near)}." if near else ""
    return (f"`{name}` is used on {_uses(code, name)} but `structure {struct}` does not declare it "
            f"(its fields: {', '.join(have) or 'none'}). Add `{name} : <type>` to `structure {struct}` "
            f"with the type it needs, and give it a value in every `{struct}` record.{alt}")


def _field_of_other(fields: dict, struct: str, name: str) -> Optional[str]:
    """Hint when `name` is a field of the *other* record (`i.done` where `done` is in `Output`)."""
    other = {"Input": ("Output", "o"), "Output": ("Input", "i")}.get(struct)
    if other and name in fields.get(other[0], []):
        mine = "i" if struct == "Input" else "o"
        return (f"`{name}` is a field of `{other[0]}`, not `{struct}`: write `{other[1]}.{name}`, "
                f"not `{mine}.{name}`. If the input also needs it, add `{name}` to `structure {struct}`.")
    return None


def collection_field_hint(code: str, owner: str, name: str) -> Optional[str]:
    """Hint for `∃ a ∈ i.accounts, a.username = …` when `Input` has no `accounts` field.

    Names the helper structure and the fields the spec reads from `a`, e.g.
    `structure Account where username : String; password : String` and
    `accounts : List Account`.
    """
    var = owner[:1].lower()
    m = re.search(rf"[∃∀]\s*(\w+)\s*∈\s*{var}\.{re.escape(name)}\b", code)
    if not m:
        return None
    elem = m.group(1)
    used = list(dict.fromkeys(re.findall(rf"(?<![\w.]){re.escape(elem)}\.(\w+)", code)))
    helper = (name[:-1] if name.endswith("s") else name + "Item")
    helper = helper[:1].upper() + helper[1:]
    struct_fields = structure_fields(code)
    if helper in struct_fields:
        decl = f"`structure {helper}` already exists"
    else:
        listed = "\n".join(f"  {f} : String" for f in used) or "  id : Nat"
        decl = (f"define it first:\n```lean\nstructure {helper} where\n{listed}\n"
                f"  deriving DecidableEq, Repr\n```\n(change each field type as needed)")
    return (f"`post` reads `{var}.{name}`, but `structure {owner}` has no field `{name}`. "
            f"Add `{name} : List {helper}` to `structure {owner}`; {decl}. Then give `{name}` a "
            f"value in every `{owner}` record of the example, e.g. `{name} := [{{ … }}]`.")


def parse_errors(output: str) -> List[dict]:
    """[{line, col, msg}] for each `error` in Lean's output (positions as Lean reports them)."""
    errors, cur = [], None
    for line in output.splitlines():
        m = _ERROR.match(line)
        if m:
            cur = {"line": int(m.group(1)), "col": int(m.group(2)), "msg": [m.group(3)]}
            errors.append(cur)
        elif _DIAG.match(line):
            cur = None
        elif cur is not None:
            cur["msg"].append(line)
    for e in errors:
        e["msg"] = "\n".join(e["msg"]).strip()
    return errors


def _trim(msg: str) -> str:
    lines = msg.splitlines()[:MAX_MSG_LINES]
    out = "\n".join(lines)
    if len(out) > MAX_MSG_CHARS:
        out = out[:MAX_MSG_CHARS] + " …"
    return out


def hint_for(msg: str, code: str) -> Optional[str]:
    """One actionable sentence for a Lean error message, or None."""
    fields = structure_fields(code)

    m = re.search(r"does not contain `([\w.]+)\.([\w?!]+)`", msg)
    if m:
        owner, name = m.group(1).split(".")[-1], m.group(2)
        if owner in fields:
            other = _field_of_other(fields, owner, name)
            if other:
                return other
            coll = collection_field_hint(code, owner, name)
            if coll:
                return coll
            return undeclared_field_hint(fields, owner, name, code)
        if owner == "Function":
            return function_field_hint(name)
        return _did_you_mean(owner, name)
    for old, new in LEAN3_NAMES.items():
        if f"`{old}`" in msg or f".{old}`" in msg:
            return f"`{old}` is Lean 3. In Lean 4 use {new}."
    m = re.search(r"[Uu]nknown (?:identifier|constant) `(\w+)\.([\w?!]+)`", msg)
    if m and m.group(1)[:1].upper() + m.group(1)[1:] in core_names():
        return _did_you_mean(m.group(1), m.group(2))
    m = re.search(r"[Uu]nknown (?:identifier|constant) `([\w?!']+)`", msg)
    if m:
        near = closest(m.group(1), local_names(code) + framework_helpers())
        if near:
            return (f"`{m.group(1)}` is not defined. Closest defined names: "
                    f"{', '.join(f'`{n}`' for n in near)}. Otherwise define it before it is used.")
    m = re.search(r"`(\w+)` is not a field of structure `(\w+)`", msg)
    if m:
        name, struct = m.group(1), m.group(2)
        other = _field_of_other(fields, struct, name)
        if other:
            return other
        return undeclared_field_hint(fields, struct, name, code)
    m = re.search(r"Constructor `(\w+)\.mk` has (\d+) explicit field", msg)
    if m:
        name = m.group(1)
        listed = ", ".join(f"{f} := …" for f in fields.get(name, [])) or "field := …"
        return (f"Build `{name}` values with named fields: `{{ {listed} }}` "
                "(every field, never `⟨…⟩`).")
    if "Invalid `⟨...⟩` notation" in msg:
        return ("`⟨…⟩` only builds structures with one constructor. Use named fields "
                "`{ field := … }` for structures, and plain values for `Nat`/`Bool`/`String`.")
    if "does not take any (non-fixed) arguments" in msg:
        return "`Spec` must not refer to itself. Write its `pre`/`post` with the fields of `i` and `o`."
    if "fail to show termination" in msg or "structural recursion" in msg or "termination_by" in msg:
        return ("Do not write recursive functions. Express the property with "
                "`List.all` / `List.any` / `List.length` / `List.count` instead.")
    m = re.search(r"None of the deriving handlers for class `\w+` applied to `(\w+)`", msg)
    if m and contains_itself(code, m.group(1)):
        name = m.group(1)
        return (f"`structure {name}` contains `{name}` itself, so Lean cannot derive it. Store "
                f"the tree flat: give `{name}` fields `id : Nat` and `parent : Option Nat` "
                f"instead of a list of `{name}`, and keep every `{name}` in one list.")
    if "has already been specified" in msg or "Fields missing" in msg:
        listed = "; ".join(f"`{k}`: {', '.join(v)}" for k, v in fields.items())
        return ("A record literal has a field twice or misses fields. In the example the input "
                "after `Spec.post` must be exactly the record given to `Spec.pre`, and the output "
                f"record lists every `Output` field once. Fields: {listed}.")
    if re.search(r"failed to synthesize[\s\S]*×", msg):
        return ("Tuples (`a × b`, `(x, y, z)`, `.1`/`.2`) have no `≤`/`<` and are hard to read. "
                "Define a helper structure with named fields and use a list of it, e.g.\n"
                "```lean\nstructure Edge where\n  src  : Nat\n  dst  : Nat\n  cost : Nat\n"
                "  deriving DecidableEq, Repr\n```\nwith `edges : List Edge` and `e.cost` instead of `e.2`.")
    if re.search(r"isSome = true →|isSome\s*=\s*true\s*→", msg) or "Option.get" in msg:
        return ("`x.get` on an `Option` needs a proof. Use `x.getD d`, or compare the option itself: "
                "`x = some v`, `x.isSome = true`.")
    if "failed to synthesize" in msg and "Decidable" in msg:
        return ("Prove the `example` with `by unfold Spec; decide`, add `deriving DecidableEq, Repr` "
                "to every structure, and inspect strings through `.toList`.")
    if "failed to synthesize" in msg:
        return ("A comparison or operation is not defined for this type. Add "
                "`deriving DecidableEq, Repr` to every structure and compare `Nat` / `Bool` fields; "
                "`<` / `≤` on `String` or on structures is not available.")
    if "proved that the proposition" in msg:
        return ("The `example` values do not satisfy your own `pre`/`post` (`decide` proved them "
                "false). Keep the definitions; change only the example values. Check string "
                "lengths character by character and redo any arithmetic.")
    if "Tactic `split` failed" in msg:
        return "`split` only splits `if`/`match`. For `∧` use `constructor`; simplest: `by unfold Spec; decide`."
    if "after decimal point" in msg:
        return "Put parentheses around a call before `.method`: `(xs.take 2).all f`, not `xs.take 2.all f`."
    if "unexpected token '!'" in msg or "unexpected token '?'" in msg:
        return ("`!`/`?` here is not valid. Negation in `pre`/`post` is `¬`; the n-th element of a list "
                "is `xs.getD n default`.")
    if "unsolved goals" in msg or ("decide" in msg and "failed" in msg):
        return ("The `example` proof does not close. Prove it with `by unfold Spec; decide`, and "
                "pick concrete values for every field that obviously satisfy `pre` and `post`.")
    if "Function expected" in msg:
        return function_expected_hint(msg)
    if "Invalid `end`" in msg:
        return "This is Lean 3 syntax. Lean 4 has no `begin`/`end`: write `by` and indented tactics."
    if "unexpected token" in msg:
        return (f"Syntax error. Use Lean 4 syntax (`fun x => e`, `by` + one tactic per line) and do "
                f"not use keywords as field names ({KEYWORDS}).")
    if re.search(r"[Uu]nknown (identifier|constant)", msg):
        return "This name is not defined. Define it before it is used, or use a Lean core name from the rules."
    if "type mismatch" in msg.lower() and ("Bool" in msg or "Prop" in msg):
        return "Bool is not Prop: compare with `= true`, and use `∧`/`∨`/`¬` (not `&&`/`||`/`!`) in `pre`/`post`."
    if "type mismatch" in msg.lower():
        return ("The types do not match. `String` is not `List Char` (use `s.toList`); a character is "
                "`'c'`, a string is `\"c\"`; both branches of an `if` must have the same type. Use the "
                "type table in the rules (counts/money → `Nat`, flags → `Bool`, text → `String`).")
    if "sorry" in msg:
        return "Do not use `sorry`; give a complete proof."
    if "timed out" in msg:
        return "Lean timed out. Make the spec and the example values smaller and simpler."
    return None


def function_field_hint(name: str) -> str:
    """`.name` was projected from a function value (`xs.map f.sum`, `(fun x => …).map`):
    list operations go on the list, after mapping."""
    return (f"`Function.{name}` does not exist: `.{name}` was applied to a function (`fun …`), not to a list. List operations go "
            f"on the list: `xs.map (fun x => …)` maps, and `(xs.map (fun x => …)).{name}` applies "
            f"`.{name}` to the mapped list.")


_FN_EXPECTED = re.compile(r"Function expected at\s+(.+?)\s+but this term has type\s+(.+?)(?:\n\s*\n|\nNote|$)",
                          re.DOTALL)


def function_expected_hint(msg: str) -> str:
    """Lean: "Function expected at X but this term has type T" — X was given an argument
    it cannot take. Only when X is `Spec` itself is the fix about `Spec.pre` / `Spec.post`."""
    m = _FN_EXPECTED.search(msg)
    term = " ".join(m.group(1).split()) if m else ""
    typ = " ".join(m.group(2).split()) if m else ""
    if not term or term == "Spec" or term.startswith("Spec "):
        return ("`Spec` is not a function: write `Spec.pre i` / `Spec.post i o`. "
                "`Contract` takes two types: `Contract Input Output`. Do not redefine `Contract`.")
    applied = "(fun …)" if "argument\n  (fun" in msg or "argument (fun" in msg else "an argument"
    dot = re.fullmatch(r"([\w.]+)\.(\w+[?!]?)", term)
    if dot:
        xs, op = dot.groups()
        return (f"`{term}` is already a value of type `{typ}`, so it cannot take {applied}. "
                f"To apply a function to each element first, map then apply: "
                f"`({xs}.map (fun x => …)).{op}`.")
    return (f"`{term}` has type `{typ}`, not a function type, so it cannot take {applied}. "
            "Remove the extra argument or use a function that takes it.")


def _did_you_mean(owner: str, name: str) -> str:
    found = suggest_names(owner, name)
    if found:
        return (f"`{owner}.{name}` does not exist in Lean core. Closest real names: "
                f"{', '.join(f'`{f}`' for f in found)}.")
    return f"`{owner}.{name}` does not exist in Lean core. Use only functions listed in the rules."


# Lean reports errors in layers: syntax, then names, then types, then proofs.
# A later layer is only meaningful once the earlier ones are fixed, so repairs
# show the model only the errors of the earliest layer present.
STAGES = ["syntax", "names", "types", "proof"]
STAGE_LABEL = {
    "syntax": "syntax errors (fix only these first)",
    "names": "unknown names or fields",
    "types": "type errors",
    "proof": "the `example` does not check",
}
_SYNTAX = re.compile(r"^(unexpected |expected |unterminated |Invalid `end`)")
_NAMES = re.compile(r"does not contain `|[Uu]nknown (identifier|constant|namespace)|"
                    r"is not a field of structure|Invalid field")
_PROOF = re.compile(r"unsolved goals|Tactic `|made no progress|proved that the proposition|"
                    r"failed to prove")


def error_stage(msg: str) -> str:
    first = msg.splitlines()[0] if msg else ""
    if _SYNTAX.search(first):
        return "syntax"
    if _NAMES.search(msg):
        return "names"
    if _PROOF.search(msg):
        return "proof"
    return "types"


def earliest_stage(output: str) -> Optional[str]:
    stages = [error_stage(e["msg"]) for e in parse_errors(output)]
    return min(stages, key=STAGES.index) if stages else None


def error_signature(output: str) -> str:
    """A short key for 'the same error again' (first error, without positions or names)."""
    errors = parse_errors(output)
    first = errors[0]["msg"].splitlines()[0] if errors else output.strip()[:200]
    return re.sub(r"`[^`]*`|\d+", "_", first)


def format_feedback(code: str, output: str, context: str = "") -> str:
    """Repair feedback for `code` that failed to check with Lean output `output`."""
    offset = HEADER.count("\n") + ((context.count("\n") + 2) if context else 0)
    code_lines = code.splitlines()
    errors = parse_errors(output)
    if not errors:
        return f"Lean output:\n{_trim(output)}"

    stage = min((error_stage(e["msg"]) for e in errors), key=STAGES.index)
    errors = [e for e in errors if error_stage(e["msg"]) == stage]
    parts, hints = [], []
    for e in errors[:MAX_ERRORS]:
        n = e["line"] - offset
        where = f"line {n}" if 1 <= n <= len(code_lines) else "locked context"
        src = f"\n    {code_lines[n - 1].strip()}" if 1 <= n <= len(code_lines) else ""
        parts.append(f"- {where}:{src}\n  error: {_trim(e['msg'])}")
        h = hint_for(e["msg"], code)
        if h and h not in hints:
            hints.append(h)
    more = len(errors) - MAX_ERRORS
    text = f"Lean errors — {STAGE_LABEL[stage]}:\n" + "\n".join(parts)
    if more > 0:
        text += f"\n(+{more} more errors, often caused by the ones above)"
    if hints:
        text += "\n\nHow to fix:\n" + "\n".join(f"- {h}" for h in hints)
    return text
