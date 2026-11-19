"""P11 strength score (evaluation/strength_score.py): mutant generation and gates, no Lean."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "evaluation"))

import strength_score as S  # noqa: E402

SPEC = """structure Input where
  qty : Nat
  stock : Nat
  deriving DecidableEq, Repr

structure Output where
  ok : Bool
  left : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.stock ≥ 1
  post := fun i o => (o.ok = true ↔ i.qty ≤ i.stock) ∧ o.left = i.stock - i.qty

example : Spec.pre { qty := 2, stock := 5 } ∧ Spec.post { qty := 2, stock := 5 } { ok := true, left := 3 } := by
  unfold Spec; decide
"""


def test_mutants_cover_every_output_field_and_skip_the_example_output():
    inp, ms = S.mutants(SPEC)
    assert inp == "{ qty := 2, stock := 5 }"
    outs = [m for k, i, m in ms if i == inp]
    assert "{ ok := true, left := 3 }" not in outs
    assert any("ok := false" in m for m in outs)
    assert any("left := 4" in m for m in outs) and any("left := 2" in m for m in outs)
    assert {k for k, _, _ in ms} == {"copy", "perturb"}


def test_copy_mutants_run_on_extra_inputs():
    _, ms = S.mutants(SPEC, ["{ qty := 9, stock := 5 }"])
    assert any(i == "{ qty := 9, stock := 5 }" and k == "copy" for k, i, _ in ms)


def test_perturb_nested_and_lists():
    types = {"Item": {"n": "Nat", "name": "String"}}
    assert S.perturb("[1, 2]", "List Nat", types) == ["[]", "[1, 2, 1, 2]", "[2]"]
    assert S.perturb("[]", "List Item", types) == ['[{ n := 0, name := "" }]']
    assert '{ n := 4, name := "a" }' in S.perturb('{ n := 3, name := "a" }', "Item", types)
    assert S.perturb("true", "Bool", types) == ["false"]


def test_local_grounding():
    entry = {"text": "The order quantity shall not exceed ten items or 500 dollars."}
    spec = SPEC.replace("i.stock ≥ 1", "i.stock ≥ 1 ∧ i.qty ≤ 10 ∧ i.stock ≤ 500")
    assert S._local_grounded(spec, entry) == (True, [])
    bad = spec.replace("i.qty ≤ 10", 'i.qty ≤ 42 ∧ "note" ≠ ""')
    ok, consts = S._local_grounded(bad, entry)
    assert not ok and "42" in consts and '"note"' in consts


def test_gates_without_lean():
    base = {"id": "X", "kind": "requirement", "lean_predicate": SPEC}
    assert S.score_spec({**base, "compiles": False}, {})["gate"].startswith("unsatisfiable")
    r = {**base, "compiles": True, "l05": {"strength": {"class": "unrealizable", "output_free": ["i.qty ≤ 3"]}}}
    assert S.score_spec(r, {})["gate"].startswith("unsatisfiable")
