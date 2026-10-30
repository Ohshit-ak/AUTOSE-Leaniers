"""L0: natural-language requirement → Lean spec."""
import json
from pathlib import Path
from typing import List

from agents.base import generate_verified

SYSTEM_PROMPT_SPEC = """\
You are a formal specification agent for Lean 4.

Given a software requirement in English, produce a Lean 4 specification
that captures the requirement precisely.

Rules:
- The framework is already imported and opened; do not write `import` lines.
- `Contract` ALREADY EXISTS. Never redefine it. Its shape, for reference only:
    structure Contract (α β : Type) where
      pre  : α → Prop
      post : α → β → Prop
- Use only Lean core (no Mathlib). For sortedness use `List.Pairwise (· ≤ ·)`,
  for permutations use `List.Perm`.
- Define `structure Input` and `structure Output` (and any helper types or
  functions) BEFORE `Spec`. Every name must be defined before it is used.
- Define the spec as `def Spec : Contract Input Output` with `pre` and `post`.
- The spec must be satisfiable: add one `example` proving
  `Spec.pre i ∧ Spec.post i o` for concrete `i`, `o`. `Spec` is not a function:
  write `Spec.pre x` / `Spec.post x y`, never `Spec x y`.
- `pre` and `post` return `Prop`: use `True`/`False`, `=`, `∧`, `∨`, `¬`, `→`.
  Do not use Bool `true`/`false` as a proposition.
- Output ONLY Lean 4 code in one ```lean block. No `sorry`.

Write Lean 4 syntax ONLY. Lean 3 does not compile. Forbidden → use instead:
- `begin ... end`            → `by` followed by indented tactics
- `λ x, e`  / `assume x,`    → `fun x => e`
- tactics separated by `,`   → one tactic per line
- `{ tac }` goal blocks      → `·` bullets, or `constructor` / `exact ⟨_, _⟩`
- `split` on `∧`             → `constructor`
- `cases h with a b`         → `obtain ⟨a, b⟩ := h`
- `#eval` / `#check` lines   → leave them out

Follow this template exactly (it compiles):

```lean
structure Input where
  amount : Nat

structure Output where
  accepted : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.amount ≤ 1000
  post := fun i o => o.accepted = true ↔ 0 < i.amount

example : Spec.pre ⟨5⟩ ∧ Spec.post ⟨5⟩ ⟨true⟩ := by
  simp [Spec]
```
"""

RUNTIME_NOTE = """\
Part of this requirement is a runtime bound. A Python benchmark measures it and
the measured value is checked against your spec with `decide`. Add each measured
value as a `Nat` field of `Output` with the field name given below, and state
the bound on it in `post`."""


def run_spec(requirement: str, model: str) -> dict:
    return generate_verified(requirement, SYSTEM_PROMPT_SPEC, model)


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
    if r.get("runtime_checks"):
        lines.append(RUNTIME_NOTE)
        for c in r["runtime_checks"]:
            lines.append(f"- `{c['lean_field']}` {c['comparator']} {c['bound']} "
                         f"({c['unit']}, operation: {c['operation']})")
    return "\n".join(lines)


def _data_constraint_prompt(d: dict) -> str:
    cons = "\n".join(f"- {k}: {v}" for k, v in d["constraints"].items())
    return (f"Data constraint {d['id']}: field `{d['field']}` ({d['description']}).\n"
            f"Constraints:\n{cons}\n"
            "Model the field as a type with these constraints as a validity predicate; "
            "`pre` takes a raw value and `post` states the predicate holds exactly when it is valid.")


def _use_case_prompt(u: dict) -> str:
    def step(s):
        line = f"  {s['step']}. [{s['actor']}] {s['text']}"
        if "goto" in s:
            line += f" (continues at {s['goto']['resolves_to']})"
        return line

    lines = [f"Use case {u['id']}: {u['name']}. Goal: {u['goal']}"]
    if u["preconditions"]:
        lines.append("Preconditions:")
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
    lines.append("Model the system state as `Input`; `pre` comes from the preconditions and "
                 "`post` from the postconditions, consistent with the steps.")
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
             "prompt": PROMPT_BUILDERS[it["kind"]](it)} for it in items]


def run_spec_from_json(path, model: str) -> List[dict]:
    return [{"id": p["id"], "kind": p["kind"], "verification": p["verification"],
             **run_spec(p["prompt"], model)}
            for p in spec_prompts(load_requirements(path))]
