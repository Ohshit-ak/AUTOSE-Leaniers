"""Mechanical syntax fixes applied to model output before Lean checks it.

Only rewrites with a single correct result belong here (Lean 3 lambdas, a Lean
keyword used as a field name, a method call on a numeric argument). Anything
that needs judgment is left to the model's repair loop. Every rewrite is
deterministic and reported, so a run's log shows what the harness changed.
"""
import re
from typing import List, Tuple

# Lean 4 keywords models use as field names. Renamed to `<kw>_` everywhere they
# appear as a field: declaration, projection and record-literal field.
KEYWORD_FIELDS = ["exists", "from", "at", "end", "in", "do", "show", "have", "then", "else",
                  "match", "with", "by", "fun", "let", "where", "if", "for", "return", "open",
                  "unless", "mut", "deriving", "instance", "class", "structure", "theorem"]

_LAMBDA3 = re.compile(r"λ\s*([^,=>]+?)\s*,")
# `xs.take 2.all f` parses as the decimal `2.all`; it needs `(xs.take 2).all f`.
_NUM_DOT = re.compile(r"(?<=\s)\d+\.(?=[A-Za-z_])")
_DOT_SPACE = re.compile(r"·\s+\.(?=[\w])")  # `(· .1)` → `(·.1)`
# `{ a := 1, a := 1, b := 2 }`: the same field with the same value twice.
_DUP_FIELD = re.compile(r"(\b\w+\s*:=\s*[^,{}]+?)\s*,\s*\1(?=\s*[,}])")
_DEBUG_CMD = re.compile(r"^\s*#(eval|check|print|reduce)\b.*$\n?", re.MULTILINE)
# A C-style `// comment` at the end of a line (Lean comments are `--`). Lines with `{`
# before the `//` are left alone: `{ x // p x }` is Lean's subtype notation.
_SLASH_COMMENT = re.compile(r"^([^\n{\"]*?\S)[ \t]+//[ \t]+([^\n]*)$", re.MULTILINE)
_FIELD_DECL = re.compile(r"^[ \t]+(\w+)\s*:\s*([^\n:=]+?)\s*(?::=.*)?$", re.MULTILINE)
_STRUCT_BODY = re.compile(r"^structure\s+\w+[^\n]*\bwhere\s*\n((?:[ \t]+.*\n?)*)", re.MULTILINE)


def _string_fields(code: str) -> List[str]:
    """Fields declared as `String` in every structure that declares them."""
    types: dict = {}
    for body in _STRUCT_BODY.findall(code):
        for name, typ in _FIELD_DECL.findall(body):
            types.setdefault(name, set()).add(typ.strip())
    return [n for n, ts in types.items() if ts == {"String"}]


def _string_all_to_list(code: str) -> str:
    """`i.raw.all p` → `i.raw.toList.all p` for `String` fields: `String.all` does not
    reduce under `decide`, and the prompt already asks for `.toList` (DD-item-name, qwen-v7)."""
    fields = _string_fields(code)
    if not fields:
        return code
    names = "|".join(re.escape(f) for f in fields)
    return re.sub(rf"(?<![\w])([a-z]\w*\.(?:{names}))\.(all|any)\b", r"\1.toList.\2", code)


def _atom_start(code: str, end: int) -> int:
    """Start index of the atom ending at `end` (exclusive): a name chain or a bracketed group,
    possibly followed by `.name` parts, e.g. `(xs.drop 3).take` or `i.raw.substring`."""
    k = end
    while k > 0:
        c = code[k - 1]
        if c.isalnum() or c in "_.?!'":
            k -= 1
        elif c in ")]":
            depth, j = 0, k - 1
            while j >= 0:
                depth += code[j] in ")]"
                depth -= code[j] in "(["
                if depth == 0:
                    break
                j -= 1
            if j < 0:
                return end
            k = j
        else:
            break
    return k


def _parenthesize_num_calls(code: str) -> str:
    """Rewrite `f a 2.g` to `(f a 2).g`, where `f` is a method call like `xs.take`."""
    for m in reversed(list(_NUM_DOT.finditer(code))):
        num_end = m.end() - 1           # index of the `.` after the number
        start, pos = None, m.start() - 1  # pos: the space before the number
        for _ in range(4):              # walk back over at most 4 arguments
            a = _atom_start(code, pos)
            if a == pos:
                break
            if "." in code[a:pos].lstrip("(["):
                start = a
                break
            if a == 0 or code[a - 1] != " ":
                break
            pos = a - 1
        if start is not None:
            code = code[:start] + "(" + code[start:num_end] + ")" + code[num_end:]
    return code


def _rename_keyword_fields(code: str, notes: List[str]) -> str:
    in_struct = False
    declared = set()
    for line in code.splitlines():
        if re.match(r"^structure\s+\w+", line):
            in_struct = True
            continue
        if in_struct:
            if not line.startswith((" ", "\t")):
                in_struct = False
                continue
            m = re.match(r"^\s+(\w+)\s*:", line)
            if m and m.group(1) in KEYWORD_FIELDS:
                declared.add(m.group(1))
    for kw in sorted(declared):
        new = f"{kw}_"
        code = re.sub(rf"^(\s+){kw}(\s*:)", rf"\g<1>{new}\2", code, flags=re.MULTILINE)  # declaration
        code = re.sub(rf"\.{kw}\b", f".{new}", code)                                    # projection
        code = re.sub(rf"([{{,]\s*){kw}(\s*:=)", rf"\g<1>{new}\2", code)                 # record literal
        notes.append(f"renamed keyword field `{kw}` to `{new}`")
    return code


_STRUCT_BLOCK = re.compile(r"^structure\s+\w+[^\n]*\bwhere[ \t]*\n((?:[ \t]+\S.*\n?|[ \t]*\n(?=[ \t]+\S))*)"
                           r"(deriving[^\n]*\n?)?", re.MULTILINE)
_DERIVE = ("DecidableEq", "Repr")


def _always_derive(code: str) -> str:
    """Every `structure` derives `DecidableEq, Repr` (`decide` needs `DecidableEq` on every
    record it compares). Missing classes are added to an existing `deriving` line;
    a structure without one gets `  deriving DecidableEq, Repr`."""
    def fix(m: re.Match) -> str:
        block, tail = m.group(0), m.group(2) or ""
        body = m.group(1)
        name = re.match(r"structure\s+(\w+)", block).group(1)
        types = " ".join(re.findall(r"^[ \t]+\w+\s*:\s*(.+)$", body, re.MULTILINE))
        # Lean cannot derive these; leave the structure to the model and the repair hints.
        if re.search(rf"→|->|\bFloat\b|\bProp\b|\bType\b|\b{re.escape(name)}\b", types):
            return block
        lines = body.splitlines(keepends=True)
        idx = next((k for k, ln in enumerate(lines) if ln.strip().startswith("deriving")), None)
        if idx is None and tail:  # `deriving` at column 0 after the fields
            have = [c.strip() for c in tail.strip()[len("deriving"):].split(",") if c.strip()]
            missing = [c for c in _DERIVE if c not in have]
            if not missing:
                return block
            new_tail = "deriving " + ", ".join(have + missing) + ("\n" if tail.endswith("\n") else "")
            return block[:len(block) - len(tail)] + new_tail
        if idx is not None:
            ln = lines[idx]
            indent = ln[:len(ln) - len(ln.lstrip())]
            have = [c.strip() for c in ln.strip()[len("deriving"):].split(",") if c.strip()]
            missing = [c for c in _DERIVE if c not in have]
            if not missing:
                return block
            lines[idx] = indent + "deriving " + ", ".join(have + missing) + ("\n" if ln.endswith("\n") else "")
            return block.replace(body, "".join(lines), 1)
        # no deriving at all: add one after the last field
        content = body.rstrip("\n")
        if not content.strip():
            return block
        indent = re.match(r"[ \t]*", content.splitlines()[-1]).group(0) or "  "
        new_body = content + f"\n{indent}deriving DecidableEq, Repr\n"
        return block[:m.start(1) - m.start(0)] + new_body + block[m.end(1) - m.start(0):]
    return _STRUCT_BLOCK.sub(fix, code)


def apply_fixups(code: str) -> Tuple[str, List[str]]:
    """Return (fixed code, notes describing each rewrite)."""
    notes: List[str] = []

    new = _LAMBDA3.sub(r"fun \1 =>", code)
    if new != code:
        notes.append("rewrote Lean 3 `λ x,` to `fun x =>`")
    code = new

    new = _parenthesize_num_calls(code)
    if new != code:
        notes.append("parenthesized a call before `.method` (e.g. `(xs.take 2).all`)")
    code = new

    new = _DOT_SPACE.sub("·.", code)
    if new != code:
        notes.append("removed the space in `(· .f)`")
    code = new

    new = _DUP_FIELD.sub(r"\1", code)
    if new != code:
        notes.append("removed a record field written twice with the same value")
    code = new

    new = _DEBUG_CMD.sub("", code)
    if new != code:
        notes.append("removed `#eval`/`#check` lines")
    code = new

    new = _SLASH_COMMENT.sub(r"\1 -- \2", code)
    if new != code:
        notes.append("rewrote `// comment` to `-- comment`")
    code = new

    new = _string_all_to_list(code)
    if new != code:
        notes.append("rewrote `s.all`/`s.any` on a String field to `s.toList.all`/`s.toList.any`")
    code = new

    code = _rename_keyword_fields(code, notes)

    new = _always_derive(code)
    if new != code:
        notes.append("added `deriving DecidableEq, Repr` to every structure")
    code = new
    return code, notes
