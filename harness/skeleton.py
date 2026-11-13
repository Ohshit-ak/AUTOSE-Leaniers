"""Spec-directed implementation skeleton for L2 (v11, issue 3). No model.

A contract's `post` is relational, but many of its conjuncts already say what the code must
be. The harness reads them and pre-fills the implementation; the model only fills what
cannot be derived:

    conjunct                                   field value / hint
    o.f = e        (e does not mention o)      f := e
    o.f = true ↔ c / c ↔ o.f = true / o.f ↔ c  f := decide (c)          (o.f = false ↔ c: decide (¬ c))
    A → o.f = e    (A is about the input)      f := if A then e else FILL; with ¬A → o.f = e' as well:
                                               f := if A then e else e'
    o.f = v ↔ c    (v not a Bool)              f := if c then v else FILL
    ∀ e ∈ o.L, P e                             L := x.M.filter (fun e => decide (P e)), M an input list
                                               of the same type (+ `.take n` when `o.L.length ≤ n`)
    anything else                              hint: "compute `o.f` so that … holds"

A field that no conjunct mentions is unconstrained: it gets the same-named input field or a
constant. `build` returns the derived fields, the holes and the hints; `render` writes the
function with `FILL` where the model must write code; `complete` says whether nothing is left
to fill (then the harness can try its own implementation, which is correct by construction
for the conjuncts it came from; PO3 still decides). Results report harness-derived and
model-written fields separately (`provenance`).
"""
import re
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple

import chain_checks as C

FILL = "FILL"
_DEFAULTS = {"Nat": "0", "Int": "0", "Bool": "false", "String": '""', "Float": "0.0"}


@dataclass
class Skeleton:
    impl: str
    dom: str
    cod: str
    values: Dict[str, str] = field(default_factory=dict)      # field → Lean expression (may contain FILL)
    how: Dict[str, str] = field(default_factory=dict)         # field → "derived" | "branch" | "free" | "hole"
    hints: List[str] = field(default_factory=list)             # what the model still has to do

    @property
    def complete(self) -> bool:
        return all(FILL not in v for v in self.values.values())

    @property
    def derived(self) -> List[str]:
        return [f for f, h in self.how.items() if h in ("derived", "free") and FILL not in self.values[f]]


def _norm(t: str) -> str:
    return " ".join(t.split())


def _split_top(text: str, op: str) -> Optional[Tuple[str, str]]:
    """(left, right) at the first top-level `op` (outside brackets), or None."""
    flat = C._mask(text)
    k = flat.find(op)
    while k >= 0:
        before, after = flat[k - 1:k], flat[k + len(op):k + len(op) + 1]
        if op == "=" and (before in ":=<>!≠" or after in "=>"):
            k = flat.find(op, k + 1)
            continue
        return text[:k].strip(), text[k + len(op):].strip()
    return None


def _rename(expr: str, var: str, to: str = "x") -> str:
    if var in ("_", to):
        return expr
    return re.sub(rf"(?<![\w.']){re.escape(var)}(?![\w'])", to, expr)


def _out_field(text: str, o: str) -> Optional[str]:
    m = re.fullmatch(rf"{re.escape(o)}\.([A-Za-z_][\w']*)", C._unparen(text))
    return m.group(1) if m else None


def _paren(e: str) -> str:
    e = e.strip()
    return e if re.fullmatch(r"[\w.'\"]+|\(.*\)|\[.*\]", e) else f"({e})"


def _negation_of(a: str, b: str) -> bool:
    """`b` is `¬ a` (or the other way round), syntactically."""
    na, nb = _norm(C._unparen(a)), _norm(C._unparen(b))
    for x, y in ((na, nb), (nb, na)):
        m = re.fullmatch(r"¬\s*(.+)", y)
        if m and _norm(C._unparen(m.group(1))) == x:
            return True
    return False


def build(c: "C.Contract", fields: Dict[str, Dict[str, str]], impl: Optional[str] = None) -> Skeleton:
    """The skeleton of `def <impl> (x : c.dom) : c.cod` from `c.post`."""
    o, i = c.out_var, c.in_var
    out_t, in_t = fields.get(c.cod, {}), fields.get(c.dom, {})
    sk = Skeleton(impl or f"{c.name}Impl", c.dom, c.cod)
    if o == "_" or not out_t:
        return sk
    branches: Dict[str, List[Tuple[str, str]]] = {}
    bounds: Dict[str, str] = {}
    pending: List[str] = []
    x = lambda e: _rename(e, i)  # noqa: E731
    mentions_o = lambda e: C._mentions(e, o)  # noqa: E731

    parts = C.conjuncts(c.post)
    for part in parts:
        p = C._unparen(part)
        # ∀ e ∈ o.L, P e
        m = re.fullmatch(rf"∀\s*\(?\s*([\w']+)\s*\)?\s*∈\s*{re.escape(o)}\.([\w']+)\s*,\s*(.+)", p, re.DOTALL)
        if m and not mentions_o(m.group(3)):
            v, lst, pred = m.group(1), m.group(2), m.group(3)
            src = [g for g, t in in_t.items() if _norm(t) == _norm(out_t.get(lst, "")) and _norm(t).startswith("List")]
            src.sort(key=lambda g: g != lst)
            if src and lst not in sk.values:
                sk.values[lst] = f"x.{src[0]}.filter (fun {v} => decide ({x(pred)}))"
                sk.how[lst] = "derived"
                continue
        # o.L.length ≤ n  (remembered: applied to a derived list with `.take`)
        m = re.fullmatch(rf"{re.escape(o)}\.([\w']+)\.length\s*(?:≤|<=)\s*(.+)", p)
        if m and not mentions_o(m.group(2)):
            bounds[m.group(1)] = (x(m.group(2)), part)
            continue
        iff = _split_top(p, "↔")
        if iff:
            lhs, rhs = iff
            for side, cond in ((lhs, rhs), (rhs, lhs)):
                if mentions_o(cond):
                    continue
                eq = _split_top(C._unparen(side), "=")
                f = _out_field(side, o) if not eq else _out_field(eq[0], o)
                val = None if not eq else C._unparen(eq[1])
                if f is None or f in sk.values:
                    continue
                typ = _norm(out_t.get(f, ""))
                if val is None and typ == "Bool":
                    sk.values[f], sk.how[f] = f"decide ({x(cond)})", "derived"
                elif val == "true":
                    sk.values[f], sk.how[f] = f"decide ({x(cond)})", "derived"
                elif val == "false":
                    sk.values[f], sk.how[f] = f"decide (¬ ({x(cond)}))", "derived"
                elif val is not None and not mentions_o(val):
                    branches.setdefault(f, []).append((x(cond), x(val)))
                else:
                    continue
                break
            else:
                pending.append(part)
            continue
        imp = _split_top(p, "→")
        if imp and not mentions_o(imp[0]):
            cond, then = imp
            done = False
            for q in C.conjuncts(then):
                eq = _split_top(C._unparen(q), "=")
                f = _out_field(eq[0], o) if eq else None
                if f and not mentions_o(eq[1]):
                    branches.setdefault(f, []).append((x(cond), x(C._unparen(eq[1]))))
                    done = True
            if not done:
                pending.append(part)
            continue
        eq = _split_top(p, "=")
        if eq:
            for lhs, rhs in (eq, eq[::-1]):
                f = _out_field(lhs, o)
                if f and not mentions_o(rhs) and f not in sk.values:
                    sk.values[f], sk.how[f] = x(C._unparen(rhs)), "derived"
                    break
            else:
                pending.append(part)
            continue
        pending.append(part)

    for f, bs in branches.items():
        if f in sk.values:
            continue
        if len(bs) == 2 and _negation_of(bs[0][0], bs[1][0]):
            sk.values[f] = f"if {bs[0][0]} then {bs[0][1]} else {bs[1][1]}"
        else:
            expr = FILL
            for cond, val in reversed(bs):
                expr = f"if {cond} then {val} else {expr}"
            sk.values[f] = expr
        sk.how[f] = "branch"
    for f, (n, part) in bounds.items():
        if f in sk.values and FILL not in sk.values[f] and sk.how.get(f) == "derived":
            sk.values[f] = f"({sk.values[f]}).take {_paren(n)}"
        else:
            pending.append(part)
    for f, t in out_t.items():
        if f in sk.values:
            continue
        if any(re.search(rf"(?<![\w.']){re.escape(o)}\.{re.escape(f)}(?![\w'])", p) for p in parts):
            sk.values[f], sk.how[f] = FILL, "hole"
            continue
        same = [g for g, tg in in_t.items() if _norm(tg) == _norm(t)]
        same.sort(key=lambda g: g != f)
        const = _DEFAULTS.get(_norm(t)) or ("[]" if _norm(t).startswith("List") else
                                            "none" if _norm(t).startswith("Option") else None)
        val = f"x.{same[0]}" if same and same[0] == f else const or (f"x.{same[0]}" if same else None)
        sk.values[f], sk.how[f] = (val, "free") if val else (FILL, "hole")
    sk.values = {f: sk.values[f] for f in out_t}            # declaration order
    sk.how = {f: sk.how[f] for f in out_t}
    for part in pending:
        fs = list(dict.fromkeys(C._refs(part, o)))
        target = ", ".join(f"`{f}`" for f in fs) or "the result"
        sk.hints.append(f"compute {target} so that `{_norm(x(part)).replace(o + '.', 'result.')}` holds")
    for f, h in sk.how.items():
        if h == "hole":
            sk.hints.append(f"write the value of `{f}`")
        elif h == "branch" and FILL in sk.values[f]:
            sk.hints.append(f"`{f}`: write the value for the remaining case (the `else {FILL}` branch)")
    return sk


def render(sk: Skeleton) -> str:
    body = ",\n    ".join(f"{f} := {v}" for f, v in sk.values.items())
    return f"def {sk.impl} (x : {sk.dom}) : {sk.cod} :=\n  {{ {body} }}"


def prompt_text(sk: Skeleton) -> str:
    """The skeleton as a prompt section ("" when nothing could be derived)."""
    if not sk.values or all(v == FILL for v in sk.values.values()):
        return ""
    derived = [f for f, h in sk.how.items() if h in ("derived", "branch") and FILL not in sk.values[f]]
    text = ("The harness derived this skeleton from the contract's `post`"
            + (f" (fields {', '.join(f'`{f}`' for f in derived)} follow directly from it)" if derived else "")
            + f". Start from it and replace every `{FILL}` with code:\n```lean\n{render(sk)}\n```")
    if sk.hints:
        text += "\nStill to do:\n" + "\n".join(f"- {h}" for h in sk.hints)
    return text


def action_for(conj: str, c: "C.Contract", fields: Dict[str, Dict[str, str]]) -> str:
    """What to change in the function so that the failing conjunct `conj` holds: an action,
    not a restatement ("add a branch on `x.mode`")."""
    o, i = c.out_var, c.in_var
    p = C._unparen(conj)
    x = lambda e: _norm(_rename(e, i))  # noqa: E731
    one = C.Contract(c.name, c.dom, c.cod, c.pre_var, c.pre, i, o, p)
    sk = build(one, fields)
    done = {f: v for f, v in sk.values.items() if sk.how.get(f) in ("derived", "branch")}
    if done:
        f, v = next(iter(done.items()))
        if v.startswith("if ") and FILL in v:
            cond = re.match(r"if (.+?) then", v).group(1)
            return f"add a branch on `{cond}`: `{f} := {v.replace(FILL, '<value otherwise>')}`"
        return f"set `{f} := {v}`"
    fs = list(dict.fromkeys(C._refs(p, o)))
    if re.search(r"\.length|[<≤>≥+\-*]|\bsum\b|\bcount\b", p):
        return (f"compute {', '.join(f'`{f}`' for f in fs) or 'the result'} from the input (count / compare / "
                f"arithmetic) so that `{x(p)}` holds; do not copy it unchanged")
    if "∀" in p or "∃" in p:
        return (f"build {', '.join(f'`{f}`' for f in fs) or 'the result'} with `List.filter` / `List.map` over an "
                f"input list so that `{x(p)}` holds for every element")
    return f"change {', '.join(f'`{f}`' for f in fs) or 'the result'} so that `{x(p)}` holds"


# ---------------------------------------------------------------------------
# Provenance: which fields of the final implementation the harness wrote
# ---------------------------------------------------------------------------

def _impl_record(code: str, impl: str) -> Optional[Dict[str, str]]:
    from validate import literal_fields
    m = re.search(rf"^def\s+{re.escape(impl)}\b[^\n]*?:=\s*(.*?)(?=^\S|\Z)", C.strip_comments(code),
                  re.MULTILINE | re.DOTALL)
    if not m:
        return None
    body = m.group(1).strip()
    if not (body.startswith("{") and body.endswith("}")) or " with " in C._mask(body[1:-1]):
        return None
    return literal_fields(body)


def provenance(code: str, sk: Optional[Skeleton]) -> Dict[str, List[str]]:
    """{"harness": fields whose final value is the skeleton's, "model": the rest}."""
    if sk is None or not sk.values:
        return {"harness": [], "model": []}
    rec = _impl_record(code, sk.impl)
    if rec is None:
        return {"harness": [], "model": list(sk.values)}
    harness = [f for f in sk.values if FILL not in sk.values[f] and f in rec
               and _norm(rec[f]) == _norm(sk.values[f])]
    return {"harness": harness, "model": [f for f in sk.values if f not in harness]}
