"""L0: natural-language requirement → Lean spec."""
import json
import re
from pathlib import Path
from typing import List

from agents.base import generate_verified

SYSTEM_PROMPT_SPEC = """\
You are a formal specification agent for Lean 4 (version 4.29, Lean core only).

Given a software requirement in English, produce a Lean 4 specification
that captures the requirement precisely.

## The framework (already imported and opened)
Do not write `import` or `open` lines. `Contract` ALREADY EXISTS; never redefine it:
    structure Contract (α β : Type) where
      pre  : α → Prop
      post : α → β → Prop

## Shape of every answer, in this order
1. `structure Input` and `structure Output`, each ending with
   `deriving DecidableEq, Repr`. Declare EVERY field you use later.
   Field types: `Nat`, `Bool`, `String`, `List Nat`, `List String`, `Option Nat`.
2. Any helper `def`s (non-recursive), each defined before it is used.
3. `def Spec : Contract Input Output where` with `pre := fun i => ...` and
   `post := fun i o => ...`.
4. One `example : Spec.pre i ∧ Spec.post i o := by unfold Spec; decide`
   with concrete values for `i` and `o`.

## Rules
- `pre` and `post` return `Prop`. Use `=`, `≠`, `≤`, `<`, `∧`, `∨`, `¬`, `→`, `↔`.
  A Bool is not a Prop: write `o.accepted = true`, never just `o.accepted`.
  Do not use `&&`, `||`, `!` in `pre`/`post`.
- Build values with named fields, listing EVERY field: `{ amount := 5, code := "A1" }`.
  Never use `⟨…⟩` for structures.
- `Spec` is not a function: write `Spec.pre i` / `Spec.post i o`, never `Spec i o`.
- Strings: inspect characters through `.toList`, e.g. `s.toList.all Char.isDigit = true`.
  Length: `s.length`. Never compare strings with `<` or `≤`.
- No recursive functions, no `partial`, no `termination_by`, no `match` on strings.
- No `sorry`, no `#eval`, no `#check`, no `theorem` other than the one `example`.
- Field names must not be keywords: exists, fun, end, at, from, have, show, do,
  let, in, then, else, match, with, where, by, type, class, instance.
- `pre` states the assumptions in the requirement. Use `fun _ => True` only if the
  requirement really has none. `post` must describe the required result; do not
  just copy input fields into the output.
- Choose example values that obviously satisfy `pre` and `post`, so `decide` succeeds.

## Choosing types (use this table)
| data in the requirement                         | Lean type                          |
| counts, quantities, sizes, limits               | `Nat`                              |
| durations, times                                | `Nat` in the smallest unit (µs)    |
| money, prices, totals                           | `Nat` cents (never parse a string) |
| yes/no, flags, states (logged in, valid)        | `Bool`                             |
| text, names, IDs, codes, dates, e-mail          | `String`, checked via `.toList`    |
| one of a fixed set (role, status)               | `String` compared with `=`         |
| collections                                     | `List T`                           |
| optional value                                  | `Option T`                         |
A `String` is not a `List Char`: convert with `s.toList`. A character is `'c'`,
a string is `"c"`. Both branches of an `if` must have the same type.

## What, not how
Specify WHAT the result must be, never HOW it is computed. If the requirement
names a method, algorithm or technology, write it as a comment
`-- IMPL: <method>` above `def Spec`, and specify only the observable result
(e.g. "uses Dijkstra" → `-- IMPL: Dijkstra`, and `post` says the result is a
shortest path). Never put conditions in comments instead of `pre`/`post`.

## Lean core functions you may use (nothing else)
- List: `xs.length`, `xs.all (fun x => ...)`, `xs.any (fun x => ...)`,
  `xs.contains x`, `xs.count x`, `xs.filter (fun x => ...)`, `xs.map (fun x => ...)`,
  `xs.sum`, `xs.Nodup`, `List.Pairwise (· ≤ ·) xs` (sorted), `List.Perm xs ys`,
  `∀ x ∈ xs, ...`, `∃ x ∈ xs, ...`
- String: `s.length`, `s.toList`, `s.isEmpty`
- Char: `c.isDigit`, `c.isAlpha`, `c.isAlphanum`, `c.isUpper`, `c.isLower`, `c == ' '`
- Option: `x.isSome`, `x.isNone`, `x.getD d`
These DO NOT exist: `List.forall`, `List.exists`, `String.forall`, `String.isNumeric`,
`String.isAlpha`. Do not use `String.all` / `String.any`; use `s.toList.all` / `s.toList.any`.

## Lean 4 syntax only (Lean 3 does not compile)
- `begin ... end`          → `by` followed by indented tactics
- `λ x, e` / `assume x,`   → `fun x => e`
- tactics separated by `,` → one tactic per line
- `split` on `∧`           → `constructor`
- `cases h with a b`       → `obtain ⟨a, b⟩ := h`

## Template: a requirement (compiles as is)
```lean
structure Input where
  amount  : Nat
  limit   : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  fee      : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.limit
  post := fun i o => (o.accepted = true ↔ i.amount ≤ i.limit) ∧
                     (o.accepted = false → o.fee = 0)

example : Spec.pre { amount := 5, limit := 10 } ∧
          Spec.post { amount := 5, limit := 10 } { accepted := true, fee := 1 } := by
  unfold Spec; decide
```

## Template: a text data field with validity rules (compiles as is)
(For a numeric data field — money, quantity, count — use `value : Nat` instead of
`raw : String`, money in cents, and state its bounds on `i.value`.)
```lean
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 8 ∧ i.raw.toList.all Char.isDigit = true)

example : Spec.pre { raw := "1234" } ∧ Spec.post { raw := "1234" } { valid := true } := by
  unfold Spec; decide
```

## Template: a use case as a state change (compiles as is)
```lean
structure Input where
  signedIn : Bool
  pending  : Nat
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  pending  : Nat
  done     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true ∧ 0 < i.pending
  post := fun i o => o.done = true ∧ o.pending = i.pending - 1 ∧ o.signedIn = i.signedIn

example : Spec.pre { signedIn := true, pending := 2 } ∧
          Spec.post { signedIn := true, pending := 2 }
                    { signedIn := true, pending := 1, done := true } := by
  unfold Spec; decide
```

Output ONLY Lean 4 code in one ```lean block.
"""

RUNTIME_NOTE = """\
Part of this requirement is a runtime bound. A Python benchmark measures it and
the measured value is checked against your spec with `decide`. Add each measured
value as a `Nat` field of `Output` with the field name given below, and state
the bound on it in `post`."""


IMPL_NOTE = """\
This requirement prescribes HOW to build something (a method, algorithm or
technology). Record that in a `-- IMPL:` comment above `def Spec`, and specify
only the observable result in `pre`/`post`."""

# Wording that marks a requirement as prescribing a method rather than a result.
IMPL_WORDS = re.compile(r"\bvia\b|\balgorithms?\b|\bby means of\b|\b(?:shall|will|must) use\b|"
                        r"\bimplemented (?:in|with|using)\b|\bwritten in\b", re.IGNORECASE)


def run_spec(requirement: str, model: str, validate=None) -> dict:
    from validate import find_witness  # imported here: validate imports agents.base
    return generate_verified(requirement, SYSTEM_PROMPT_SPEC, model, validate=validate,
                             find_witness=find_witness)


# ---------------------------------------------------------------------------
# Requirements JSON (from req_parser.py) → one prompt per entry.
# Rendering is deterministic, so the same JSON always gives the same prompts.
# ---------------------------------------------------------------------------

def load_requirements(path) -> dict:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def _requirement_prompt(r: dict) -> str:
    lines = [f"Requirement {r['id']} ({' > '.join(r['section_path'])}):", r["text"]]
    if r.get("ignore_terms"):
        lines.append(f"Ignore these non-formal words: {', '.join(r['ignore_terms'])}.")
    for q in r.get("quantities", []):
        if q["kind"] == "count" and not r.get("runtime_checks"):
            lines.append(f"Bound: {q['unit']} {q['comparator']} {q['value']}.")
    if IMPL_WORDS.search(r["text"]):
        lines.append(IMPL_NOTE)
    if r.get("runtime_checks"):
        lines.append(RUNTIME_NOTE)
        for c in r["runtime_checks"]:
            lines.append(f"- `{c['lean_field']}` {c['comparator']} {c['bound']} "
                         f"({c['unit']}, operation: {c['operation']})")
    return "\n".join(lines)


# Parser constraint keys/values that mean the field holds a number, not text.
NUMERIC_TYPES = {"money", "number", "integer", "count", "quantity"}


def _is_numeric_field(c: dict) -> bool:
    return c.get("type") in NUMERIC_TYPES or "default" in c or "max_ref" in c


def _data_constraint_prompt(d: dict) -> str:
    c = d["constraints"]
    cons = "\n".join(f"- {k}: {v}" for k, v in c.items())
    if _is_numeric_field(c):
        shape = ("This field holds a NUMBER: `Input` is `value : Nat`"
                 + (" (money in cents, e.g. $12.34 = 1234)" if c.get("type") == "money" else "")
                 + ", `Output` has `valid : Bool`, and `post` says `o.valid = true` exactly when "
                 "the bounds on `i.value` hold. Do not use a `String`.")
    else:
        shape = ("Follow the text data-field template: `Input` is `raw : String`, `Output` has "
                 "`valid : Bool`, and `post` says `o.valid = true` exactly when every constraint holds.")
    return (f"Data constraint {d['id']}: field `{d['field']}` ({d['description']}).\n"
            f"Constraints:\n{cons}\n{shape}")


def _use_case_prompt(u: dict) -> str:
    def step(s):
        line = f"  {s['step']}. [{s['actor']}] {s['text']}"
        if "goto" in s:
            line += f" (continues at {s['goto']['resolves_to']})"
        return line

    lines = [f"Use case {u['id']}: {u['name']}. Goal: {u['goal']}"]
    if u["preconditions"]:
        lines.append("Preconditions (`pre` must state these; it must not be `True`):")
        lines += [f"  - {p}" for p in u["preconditions"]]
    if u["basic_scenario"]:
        lines.append("State-changing steps:")
        lines += [step(s) for s in u["basic_scenario"]]
    for f in u["alternative_scenarios"]:
        lines.append(f"Alternative flow {f['flow']}:")
        lines += [step(s) for s in f["steps"]]
    if u["postconditions"]:
        lines.append("Postconditions:")
        lines += [f"  - {p}" for p in u["postconditions"]]
    lines.append("Follow the use-case template: `Input` is the state before, `Output` the state after; "
                 "`pre` comes from the preconditions and `post` from the postconditions, "
                 "consistent with the steps.")
    return "\n".join(lines)


PROMPT_BUILDERS = {
    "requirement": _requirement_prompt,
    "data_constraint": _data_constraint_prompt,
    "use_case": _use_case_prompt,
}


def spec_prompts(doc: dict) -> List[dict]:
    """[{id, kind, verification, text, prompt}] in document order."""
    items = doc["requirements"] + doc["data_dictionary"] + doc["use_cases"]
    return [{"id": it["id"], "kind": it["kind"],
             "verification": it.get("verification", "lean"),
             "text": it.get("text") or it.get("description") or f"{it.get('name')}: {it.get('goal')}",
             "prompt": PROMPT_BUILDERS[it["kind"]](it), "entry": it} for it in items]


def run_spec_from_json(path, model: str) -> List[dict]:
    return [{"id": p["id"], "kind": p["kind"], "verification": p["verification"],
             **run_spec(p["prompt"], model)}
            for p in spec_prompts(load_requirements(path))]
