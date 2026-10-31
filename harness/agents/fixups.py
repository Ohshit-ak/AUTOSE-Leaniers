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

    code = _rename_keyword_fields(code, notes)
    return code, notes
