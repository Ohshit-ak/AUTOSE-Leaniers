"""Counterexamples for failed PO3 obligations (P1). No model; Lean `#eval` only.

When the harness cannot prove `C.Satisfies Impl`, the repair feedback so far only named the
`post` conjunct that does not follow. A concrete input is easier to act on:

    for input X your function returns Y, but `post` needs Z (`<conjunct>` is false)

`find(prefix, contract, impl, types)`:
  1. enumerates small inputs of the contract's argument type: the L0 example's input literal
     (when the argument type is `Input`), then single-field and a few seeded multi-field
     changes drawn from the spec's own numbers and strings (`validate._pool`), one level of
     nested structures and one-element lists;
  2. evaluates, in ONE Lean run, `decide (pre x)`, `decide (post x (Impl x))`, each conjunct of
     `post`, and `repr (Impl x)`;
  3. for the first input with `pre` true and `post` false, looks (second Lean run) for an output
     Z that `post` accepts, by changing the fields of Y one or two at a time.

Everything it reports was evaluated by Lean on concrete values, so a reported counterexample
is real. When nothing is decidable, no literal can be built, or no input violates `post`
(the proof failed for tactic reasons), it returns None and the feedback is unchanged.

`triage(...)` uses the same machinery to sort a stored PO3 failure into
    unsatisfiable-spec   for some input satisfying `pre`, no candidate output satisfies `post`
    wrong-code           a concrete input where Impl violates `post` (and some output works)
    tactics              no counterexample found among the inputs tried (the proof is the problem,
                         or the search was too small; reported as such, never as "correct")
"""
import itertools
import random
import re
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple

import chain_checks as C
from lean_runner import check_lean
from validate import _pool, example_witness, field_types, literal_fields, split_example

MAX_INPUTS = 40
MAX_OUTPUTS = 120
_STRUCT_HEAD = re.compile(r"^structure\s+([\w.']+)[^\n]*\bwhere\b(.*?)(?=^\S|\Z)", re.MULTILINE | re.DOTALL)
_LINE = re.compile(r"^CEX\|(\d+)\|(\w+)\|(.*)$", re.MULTILINE)


@dataclass
class Counterexample:
    input: str                      # Lean literal
    output: str                     # what Impl returns (Repr)
    failing: List[str]              # conjuncts of `post` that are false
    needed: Optional[str] = None    # an output `post` accepts for this input
    changed: List[str] = field(default_factory=list)   # fields of `needed` that differ
    tried: int = 0                  # inputs evaluated

    def message(self, impl: str, contract: str) -> str:
        text = f"for input `{self.input}` your function `{impl}` returns `{self.output}`"
        if self.needed:
            text += (f", but `{contract}.post` needs e.g. `{self.needed}`"
                     + (f" (change {', '.join(f'`{f}`' for f in self.changed)})" if self.changed else ""))
        else:
            text += f", which `{contract}.post` rejects"
        if self.failing:
            text += "; false for this input: " + "; ".join(f"`{' '.join(c.split())}`" for c in self.failing[:3])
        return text + "."


# ---------------------------------------------------------------------------
# Values
# ---------------------------------------------------------------------------

def _norm(t: str) -> str:
    return " ".join(t.split())


def _numbers_strings(code: str) -> Tuple[List[int], List[str]]:
    defs = split_example(code)[0]
    nums = sorted({int(n) for n in re.findall(r"(?<![\w.])(\d{1,7})(?![\w.])", defs)})[:8]
    strs = sorted(set(re.findall(r'"[^"\n]*"', defs)))[:8]
    return nums, strs


class _Values:
    """Candidate literals per type, built from the spec's own constants."""

    def __init__(self, types: Dict[str, Dict[str, str]], nums: List[int], strs: List[str]):
        self.types, self.nums, self.strs = types, nums, strs

    def pool(self, t: str, orig: Optional[str] = None, depth: int = 0) -> List[str]:
        t = _norm(t).strip("()")
        if t in self.types:
            base = self.default(t, depth)
            return [v for v in dict.fromkeys(([orig] if orig else []) + ([base] if base else []))]
        m = re.fullmatch(r"List\s+\(?([\w.']+)\)?", t)
        if m:
            inner = self.pool(m.group(1), None, depth + 1) if depth < 2 else []
            vals = ([orig] if orig else []) + ["[]"] + [f"[{v}]" for v in inner[:3]]
            if len(inner) >= 2:
                vals.append(f"[{inner[0]}, {inner[1]}]")
            return list(dict.fromkeys(vals))
        m = re.fullmatch(r"Option\s+\(?([\w.']+)\)?", t)
        if m:
            inner = self.pool(m.group(1), None, depth + 1) if depth < 2 else []
            return list(dict.fromkeys(([orig] if orig else []) + ["none"] + [f"(some {v})" for v in inner[:2]]))
        if t == "Int":
            return list(dict.fromkeys(([orig] if orig else []) + ["0", "1", "-1"] + [str(n) for n in self.nums]))
        return _pool(t, orig, self.nums, self.strs)

    def default(self, t: str, depth: int = 0) -> Optional[str]:
        fs = self.types.get(t)
        if fs is None:
            p = self.pool(t, None, depth + 1) if depth < 3 else []
            return p[0] if p else None
        if depth >= 3:
            return None
        vals = {}
        for f, ft in fs.items():
            v = self.default(ft, depth + 1) if _norm(ft) in self.types else (self.pool(ft, None, depth + 1) or [None])[0]
            if v is None:
                return None
            vals[f] = v
        return "{ " + ", ".join(f"{f} := {v}" for f, v in vals.items()) + " }"


def candidate_inputs(dom: str, types, code: str, seed_literal: Optional[str] = None,
                     limit: int = MAX_INPUTS, seed: int = 0) -> List[str]:
    """Input literals of type `dom`: the seed (the L0 example's input), single-field changes,
    then seeded random combinations. Deterministic for a given seed."""
    fs = types.get(dom)
    if not fs:
        return []
    nums, strs = _numbers_strings(code)
    vals = _Values(types, nums, strs)
    lit = literal_fields(seed_literal) if seed_literal else {}
    if set(lit) != set(fs):
        lit = {}
    pools = {f: vals.pool(t, lit.get(f)) for f, t in fs.items()}
    if not all(pools.values()):
        return []
    base = {f: (lit.get(f) or pools[f][0]) for f in fs}
    out = [base]
    for f, vs in pools.items():
        for v in vs:
            if v != base[f]:
                out.append({**base, f: v})
    rng = random.Random(seed)
    names = list(fs)
    for _ in range(limit * 3):
        if len(out) >= limit * 2:
            break
        out.append({f: rng.choice(pools[f]) for f in names})
    lits, seen = [], set()
    for r in out:
        s = "{ " + ", ".join(f"{f} := {r[f]}" for f in names) + " }"
        if s not in seen:
            seen.add(s)
            lits.append(s)
    return lits[:limit]


# ---------------------------------------------------------------------------
# Lean script
# ---------------------------------------------------------------------------

def _rename(expr: str, var: str, to: str) -> str:
    if var in ("_", to):
        return expr
    return re.sub(rf"(?<![\w.']){re.escape(var)}(?![\w'])", to, expr)


def _repr_instances(code: str, names: List[str]) -> str:
    """`deriving instance Repr for S` for the structures among `names` that lack it."""
    out = []
    for m in _STRUCT_HEAD.finditer(C.strip_comments(code)):
        if m.group(1) in names and not re.search(r"\bRepr\b", m.group(0)):
            out.append(f"deriving instance Repr for {m.group(1)}")
    return "\n".join(out)


def _structs_used(t: str, types, acc=None) -> List[str]:
    acc = acc if acc is not None else []
    for w in re.findall(r"[\w.']+", t):
        if w in types and w not in acc:
            acc.append(w)
            for ft in types[w].values():
                _structs_used(ft, types, acc)
    return acc


def _pred_defs(c: "C.Contract") -> Tuple[str, List[str]]:
    """Bool versions of `pre`, `post` and each `post` conjunct, over `x__` / `o__`."""
    pre = _rename(c.pre, c.pre_var, "x__") if c.pre_var != "_" else c.pre
    post = _rename(_rename(c.post, c.in_var, "x__"), c.out_var, "o__")
    parts = [_rename(_rename(p, c.in_var, "x__"), c.out_var, "o__") for p in C.conjuncts(c.post)]
    lines = [f"def cex__pre (x__ : {c.dom}) : Bool := decide ({pre})",
             f"def cex__post (x__ : {c.dom}) (o__ : {c.cod}) : Bool := decide ({post})"]
    for k, p in enumerate(parts):
        lines.append(f"def cex__c{k} (x__ : {c.dom}) (o__ : {c.cod}) : Bool := decide ({p})")
    return "\n".join(lines), C.conjuncts(c.post)


def _run(script: str) -> Tuple[str, bool]:
    r = check_lean(script)
    return (r.get("output") or r.get("error") or ""), r["success"]


def evaluate(prefix: str, c: "C.Contract", impl: str, inputs: List[str]) -> Optional[List[dict]]:
    """[{input, pre, post, output, failing}] per input, or None when the predicates or the
    implementation could not be evaluated."""
    types = field_types(prefix)
    preds, parts = _pred_defs(c)
    lines = [prefix, _repr_instances(prefix, _structs_used(c.cod, types)), preds]
    for k, lit in enumerate(inputs):
        conj = " ++ ".join(f'(if cex__c{j} x o then "1" else "0")' for j in range(len(parts))) or '""'
        lines.append(
            f"#eval (do\n  let x : {c.dom} := {lit}\n  if cex__pre x then\n    let o := {impl} x\n"
            f"    IO.println (\"CEX|{k}|\" ++ (if cex__post x o then \"ok\" else \"bad\") ++ \"|\" ++ {conj} ++ \"|\" ++ "
            f"(toString (repr o)).replace \"\\n\" \" \")\n"
            f"  else IO.println \"CEX|{k}|nopre|\" : IO Unit)")
    out, _ = _run("\n\n".join(x for x in lines if x))
    rows = {int(k): (st, rest) for k, st, rest in _LINE.findall(out)}
    if not rows:
        return None
    res = []
    for k, lit in enumerate(inputs):
        if k not in rows:
            continue
        st, rest = rows[k]
        if st == "nopre":
            res.append({"input": lit, "pre": False})
            continue
        bits, _, rep = rest.partition("|")
        failing = [p for p, b in zip(parts, bits) if b == "0"]
        res.append({"input": lit, "pre": True, "post": st == "ok", "output": " ".join(rep.split()),
                    "failing": failing})
    return res


def output_candidates(out_lit: str, cod: str, types, code: str, x_lit: Optional[str] = None,
                      limit: int = MAX_OUTPUTS) -> List[Tuple[str, List[str]]]:
    """[(output literal, changed fields)]: `out_lit` with one, then two fields replaced."""
    fs = types.get(cod)
    cur = literal_fields(out_lit) if out_lit.strip().startswith("{") else {}
    if not fs or set(cur) != set(fs):
        return []
    nums, strs = _numbers_strings(code)
    vals = _Values(types, nums, strs)
    xin = literal_fields(x_lit) if x_lit else {}
    in_t = types.get(next((d for d in types if x_lit and set(types[d]) == set(xin)), ""), {})
    pools = {}
    for f, t in fs.items():
        same = [xin[g] for g, tg in in_t.items() if _norm(tg) == _norm(t) and g in xin]
        pools[f] = [v for v in dict.fromkeys(same + vals.pool(t)) if v != cur[f]][:8]
    out = []
    for f in fs:
        for v in pools[f]:
            out.append(({**cur, f: v}, [f]))
    for f, g in itertools.combinations(fs, 2):
        for v, w in itertools.product(pools[f][:4], pools[g][:4]):
            out.append(({**cur, f: v, g: w}, [f, g]))
            if len(out) >= limit:
                break
    return [("{ " + ", ".join(f"{f} := {r[f]}" for f in fs) + " }", ch) for r, ch in out[:limit]]


def needed_output(prefix: str, c: "C.Contract", x_lit: str, y_lit: str) -> Optional[Tuple[str, List[str]]]:
    """An output `post` accepts for input `x_lit`, close to `y_lit`, or None."""
    types = field_types(prefix)
    cands = output_candidates(y_lit, c.cod, types, prefix, x_lit)
    if not cands:
        return None
    preds, _ = _pred_defs(c)
    lines = [prefix, preds]
    for k, (o, _) in enumerate(cands):
        lines.append(f"#eval (if cex__post ({x_lit} : {c.dom}) ({o} : {c.cod}) then IO.println \"CEX|{k}|ok|\" "
                     f"else pure () : IO Unit)")
    out, _ = _run("\n\n".join(lines))
    hits = sorted(int(k) for k, st, _ in _LINE.findall(out) if st == "ok")
    return cands[hits[0]] if hits else None


def seed_literal(code: str, dom: str) -> Optional[str]:
    """The L0 example's input literal when the contract reads `Input`."""
    if dom != "Input":
        return None
    w = example_witness(code)
    return w[0] if w else None


def find(prefix: str, c: "C.Contract", impl: str, seed_code: Optional[str] = None,
         limit: int = MAX_INPUTS) -> Optional[Counterexample]:
    """A concrete input on which `impl` violates `c.post` (with `c.pre` true), or None."""
    if c is None or c.out_var == "_":
        return None
    types = field_types(prefix)
    inputs = candidate_inputs(c.dom, types, prefix, seed_literal(seed_code or prefix, c.dom), limit)
    if not inputs:
        return None
    rows = evaluate(prefix, c, impl, inputs)
    if not rows:
        return None
    bad = next((r for r in rows if r.get("pre") and not r["post"]), None)
    if bad is None:
        return None
    cex = Counterexample(bad["input"], bad["output"], bad["failing"], tried=len(rows))
    got = needed_output(prefix, c, bad["input"], bad["output"])
    if got:
        cex.needed, cex.changed = got
    return cex


def triage(prefix: str, c: "C.Contract", impl: str, seed_code: Optional[str] = None) -> dict:
    """{"class": unsatisfiable-spec | wrong-code | tactics | unevaluable, ...} for a PO3 failure."""
    if c is None:
        return {"class": "unevaluable", "why": "contract not parsed"}
    types = field_types(prefix)
    inputs = candidate_inputs(c.dom, types, prefix, seed_literal(seed_code or prefix, c.dom))
    if not inputs:
        return {"class": "unevaluable", "why": "no input literal could be built"}
    rows = evaluate(prefix, c, impl, inputs)
    if not rows:
        return {"class": "unevaluable", "why": "predicates or implementation could not be evaluated"}
    with_pre = [r for r in rows if r.get("pre")]
    bad = [r for r in with_pre if not r["post"]]
    if not bad:
        return {"class": "tactics", "inputs": len(rows), "with_pre": len(with_pre)}
    for r in bad[:3]:
        got = needed_output(prefix, c, r["input"], r["output"])
        if got:
            return {"class": "wrong-code", "input": r["input"], "output": r["output"], "needed": got[0],
                    "failing": r["failing"], "inputs": len(rows), "with_pre": len(with_pre)}
    return {"class": "unsatisfiable-spec", "input": bad[0]["input"], "output": bad[0]["output"],
            "failing": bad[0]["failing"], "inputs": len(rows), "with_pre": len(with_pre),
            "why": "no output tried satisfies post for this input (search, not proof)"}
