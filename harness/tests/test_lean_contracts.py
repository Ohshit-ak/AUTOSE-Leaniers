"""Tests that run Lean (marker `lean`; the replays are also `slow`).

    interface contracts   what the harness relies on from `check_lean` and Lean's output format
    framework laws        algebraic laws of Contract / seq / Refines, proved once for all inputs
    properties            Lean as the oracle: string helpers vs a Python reference, skeletons
                          correct by construction, error attribution of batched theorems
    metamorphic           a verified file stays verified under renaming, and stops being
                          accepted when its proof is replaced by `sorry` or its code is broken
    replay                recorded verdicts (`full_check`) are reproduced by Lean today
"""
import re

import pytest
from hypothesis import given, settings
from hypothesis import strategies as st

import chain_checks as C
import po
import skeleton as SK
import validate as V
from agents import repair as R
from lean_runner import HEADER, check_lean

from . import corpus
from . import strategies as S

pytestmark = pytest.mark.lean
LEAN = settings(max_examples=4, deadline=None)


# ---------------------------------------------------------------------------
# Interface contracts: lean_runner.check_lean and the output format repair.py parses
# ---------------------------------------------------------------------------

def test_check_lean_result_shape_and_error_format():
    ok = check_lean("example : 2 + 2 = 4 := by decide")
    assert ok == {"success": True, "output": ok["output"]}
    bad = check_lean("example : 2 + 2 = 5 := by decide\n\ndef x : Nat := \"a\"")
    assert bad["success"] is False and set(bad) == {"success", "error"}
    errs = R.parse_errors(bad["error"])
    # positions are in the checked file: HEADER comes first, so line 1 of the code is line 4
    assert [e["line"] for e in errs] == [HEADER.count("\n") + 1, HEADER.count("\n") + 3]
    assert R.error_stage(errs[0]["msg"]) == "proof" and R.error_stage(errs[1]["msg"]) == "types"
    assert "/tmp" not in bad["error"] and "<generated>" in bad["error"]


def test_sorry_imports_and_the_framework_prelude():
    assert check_lean("theorem t : 1 = 2 := by sorry")["success"] is False       # `sorry` only warns in Lean
    assert check_lean("import Mathlib\nimport ContractForge\nexample : True := trivial")["success"]  # imports dropped
    assert check_lean("def c : Contract Nat Nat := { pre := fun _ => True, post := fun x y => y = x }\n"
                      "example : c.Satisfies id := by discharge_po3 [c]")["success"]   # namespace is open


@LEAN
@given(st.lists(st.tuples(st.booleans(), st.integers(0, 3)), min_size=1, max_size=6))
def test_run_theorems_blames_exactly_the_theorems_that_fail(cases):
    """Several theorems in one Lean run, of different lengths: each failure is attributed to its own theorem."""
    thms = [f"example : {k} + 2 = {k + 2 if ok else k + 3} := by\n" + "  skip\n" * pad + "  decide"
            for k, (ok, pad) in enumerate(cases)]
    res = po.run_theorems("def unused : Nat := 1", thms)
    assert [ok for ok, _ in res] == [ok for ok, _ in cases]
    assert all(bool(errs) != ok for ok, errs in res)
    assert V._check_examples("def unused : Nat := 1", thms) == [ok for ok, _ in cases]


def test_a_broken_prefix_fails_every_theorem():
    res = po.run_theorems("def broken : Nat := \"x\"", ["example : True := trivial", "example : 1 = 1 := rfl"])
    assert [ok for ok, _ in res] == [False, False]
    assert po.prove("", "theorem t : 2 + 2 = 4", ["omega_typo", "decide"]) == ("decide", [])
    assert po.prove("", "theorem t : 2 + 2 = 5", ["decide"])[0] is None


# ---------------------------------------------------------------------------
# Framework laws (proved for every contract: stronger than any sample)
# ---------------------------------------------------------------------------

LAWS = """
namespace Laws
open ContractForge.Contract
variable {α β γ δ : Type}

theorem refines_refl (c : Contract α β) : c.Refines c := ⟨fun _ h => h, fun _ _ _ h => h⟩

theorem refines_trans {a b c : Contract α β} (h1 : a.Refines b) (h2 : b.Refines c) : a.Refines c :=
  ⟨fun x hx => h1.1 x (h2.1 x hx), fun x y hx hp => h2.2 x y hx (h1.2 x y (h2.1 x hx) hp)⟩

-- PO1 survives weakening what the second component assumes and strengthening what the first gives.
theorem compatible_mono {a a' : Contract α β} {b b' : Contract β γ} (h : Compatible a b)
    (hpre : ∀ x, a'.pre x → a.pre x) (hpost : ∀ x y, a'.pre x → a'.post x y → a.post x y)
    (hb : ∀ y, b.pre y → b'.pre y) : Compatible a' b' :=
  fun x y hx hp => hb y (h x y (hpre x hx) (hpost x y hx hp))

-- An implementation of a contract also meets every contract it refines (PO3 is monotone).
theorem satisfies_mono {c s : Contract α β} {f : α → β} (hr : c.Refines s) (hf : c.Satisfies f) :
    s.Satisfies f := refines_sound hr hf

-- seq is associative up to refinement, in both directions.
theorem seq_assoc_l (a : Contract α β) (b : Contract β γ) (c : Contract γ δ) :
    ((a.seq b).seq c).Refines (a.seq (b.seq c)) := by
  refine ⟨fun _ h => h, ?_⟩
  intro x z _ h
  obtain ⟨y2, ⟨y1, h1, h2⟩, h3⟩ := h
  exact ⟨y1, h1, y2, h2, h3⟩

theorem seq_assoc_r (a : Contract α β) (b : Contract β γ) (c : Contract γ δ) :
    (a.seq (b.seq c)).Refines ((a.seq b).seq c) := by
  refine ⟨fun _ h => h, ?_⟩
  intro x z _ h
  obtain ⟨y1, h1, y2, h2, h3⟩ := h
  exact ⟨y2, ⟨y1, h1, h2⟩, h3⟩

-- The single-component path of the pipeline is the two-component theorem with nothing to compose.
theorem single_is_sound {s : Contract α β} {f : α → β} (hf : s.Satisfies f) : s.Satisfies f :=
  refines_sound (refines_refl s) hf

-- PO1 is necessary: two components that each meet their contract need not meet the composed one.
theorem po1_is_necessary : ¬ ∀ (a b : Contract Nat Nat) (f g : Nat → Nat),
    a.Satisfies f → b.Satisfies g → (a.seq b).Satisfies (g ∘ f) := by
  intro h
  have key := h ⟨fun _ => True, fun _ y => y = 0⟩ ⟨fun y => y = 1, fun y z => z = 5 ∧ y = 1⟩
    (fun _ => 0) (fun _ => 5) (fun _ _ => rfl) (fun _ hy => ⟨rfl, hy⟩) 0 trivial
  obtain ⟨y, h0, _, h1⟩ := key
  omega

-- PO2 is necessary: a contract that does not refine the spec gives no guarantee about it.
theorem po2_is_necessary : ¬ ∀ (c s : Contract Nat Nat) (f : Nat → Nat), c.Satisfies f → s.Satisfies f := by
  intro h
  have key := h ⟨fun _ => True, fun _ _ => True⟩ ⟨fun _ => True, fun _ y => y = 1⟩ (fun _ => 0)
    (fun _ _ => trivial) 0 trivial
  exact absurd key (by decide)

-- String helpers.
open ContractForge
theorem allDigits_append (a b : List Char) : allDigits (a ++ b) = (allDigits a && allDigits b) := by
  simp [allDigits]
theorem allAlnum_append (a b : List Char) : allAlnum (a ++ b) = (allAlnum a && allAlnum b) := by
  simp [allAlnum]
theorem lenBetween_iff (lo hi : Nat) (cs : List Char) : lenBetween lo hi cs = true ↔ lo ≤ cs.length ∧ cs.length ≤ hi := by
  simp [lenBetween]
theorem splitOn_ne_nil (sep : Char) (cs : List Char) : splitOn sep cs ≠ [] := by
  induction cs with
  | nil => simp [splitOn]
  | cons c cs ih =>
    unfold splitOn
    split
    · contradiction
    · split <;> simp
end Laws
"""


def test_framework_laws_hold():
    r = check_lean(LAWS)
    assert r["success"], r.get("error", "")[:3000]


# ---------------------------------------------------------------------------
# Properties with Lean as the oracle
# ---------------------------------------------------------------------------

def _two_digits(s, lo, hi):
    return len(s) == 2 and all(c in "0123456789" for c in s) and lo <= int(s) <= hi


def _digits(s):
    return all(c in "0123456789" for c in s)


REFERENCE = {
    "allDigits": _digits,
    "allAlnum": lambda s: all(c.isascii() and c.isalnum() for c in s),
    "lenBetween 2 5": lambda s: 2 <= len(s) <= 5,
    "isMMYY": lambda s: len(s) == 5 and s[2] == "/" and _two_digits(s[:2], 1, 12) and _digits(s[3:]),
    "isMMDDYYYY": lambda s: (len(s) == 10 and s[2] == "/" and s[5] == "/" and _two_digits(s[:2], 1, 12)
                             and _two_digits(s[3:5], 1, 31) and _digits(s[6:])),
    "isMonth": lambda s: _two_digits(s, 1, 12),
    "isDay": lambda s: _two_digits(s, 1, 31),
}
_dates = st.one_of(st.text(alphabet="0123456789/-a Zé٣", max_size=11),
                   st.builds("{:02d}/{:02d}".format, st.integers(0, 14), st.integers(0, 99)),
                   st.builds("{:02d}/{:02d}/{:04d}".format, st.integers(0, 14), st.integers(0, 33), st.integers(0, 9999)),
                   st.builds("{:02d}".format, st.integers(0, 40)))


@LEAN
@given(st.lists(st.tuples(st.sampled_from(sorted(REFERENCE)), _dates), min_size=30, max_size=30, unique=True))
def test_string_helpers_agree_with_a_python_reference(cases):
    """Differential: Lean's kernel evaluates each helper (`decide`) to what the reference predicts."""
    exs = [f'example : {fn} "{s}".toList = {"true" if REFERENCE[fn](s) else "false"} := by decide' for fn, s in cases]
    exs += [f'example : (splitOn \'/\' "{s}".toList).length = {s.count("/") + 1} := by decide' for _, s in cases[:10]]
    wrong = [ex for ex, ok in zip(exs, V._check_examples("", exs)) if not ok]
    assert not wrong, wrong[:3]


@LEAN
@given(st.lists(S.spec_models(), min_size=6, max_size=6))
def test_a_complete_skeleton_is_correct_by_construction_and_a_mutant_is_not(models):
    """For specs whose `post` fixes every output field, the harness's own implementation proves
    PO3; the same implementation with one `Nat` field off by one does not (Lean decides both)."""
    good, mutants = [], []
    for k, m in enumerate(models):
        code = m.code()
        sk = SK.build(C.spec_contract(code), V.field_types(code))
        assert sk.complete
        impl = SK.render(sk)
        proof = f"theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by\n  discharge_po3 [Spec, SpecImpl]"
        good.append(f"namespace G{k}\n{code}\n\n{impl}\n\n{proof}\nend G{k}")
        f = next((f for f, t in m.outputs.items() if t == "Nat"), None)
        if f and not m.pre:                                     # a contradictory `pre` makes any code correct
            broken = impl.replace(f"{f} := {sk.values[f]}", f"{f} := ({sk.values[f]}) + 1", 1)
            mutants.append(f"namespace M{k}\n{code}\n\n{broken}\n\n{proof}\nend M{k}")
    res = po.run_theorems("", good + mutants)
    assert [ok for ok, _ in res[:len(good)]] == [True] * len(good), [e for _, e in res[:len(good)] if e][:1]
    assert [ok for ok, _ in res[len(good):]] == [False] * len(mutants)


@LEAN
@given(S.spec_models(max_out=2))
def test_trivial_witness_is_found_exactly_for_copy_specs(m):
    """A spec that only copies inputs is weak (a witness exists and is a record of copies);
    one that asks for `input + 1` on some field is not satisfied by copies and constants."""
    nat_in = next(f for f, t in m.inputs.items() if t == "Nat")
    copy = S.SpecModel({nat_in: "Nat"}, {"result": "Nat"}, m.pre, {"result": f"o.result = i.{nat_in}"})
    w = C.trivial_witness(copy.code())
    assert w == f"{{ result := x.{nat_in} }}"
    work = S.SpecModel({nat_in: "Nat"}, {"result": "Nat"}, [], {"result": f"o.result = i.{nat_in} + 1"})
    assert C.trivial_witness(work.code()) is None


# ---------------------------------------------------------------------------
# Recorded runs: replay and metamorphic relations on verified files
# ---------------------------------------------------------------------------

def _latest(full: bool):
    return [(rep, e) for rep, e in corpus.all_records((corpus.LATEST_CHAIN,))
            if (e.get("full_check") is True) == full and (full or e.get("l2"))]


VERIFIED = corpus.sample(_latest(True), 24)
CHAINS = corpus.sample([(r, e) for r, e in _latest(True) if e["l1"]["mode"] == "chain"], 6)
FAILED_L2 = corpus.sample([(r, e) for r, e in _latest(False) if e["l1"]["success"] and not all(x["success"] for x in e["l2"])], 6)
_id = lambda t: f"{t[0].parent.parent.name}/{t[0].name}/{t[1]['id']}"  # noqa: E731


@pytest.mark.slow
@pytest.mark.parametrize("case", VERIFIED + CHAINS, ids=_id)
def test_replay_a_verified_file_is_still_accepted_by_lean(case):
    rep, e = case
    text = corpus.lean_path(rep, e["id"]).read_text(encoding="utf-8")
    assert "theorem system_ok : Spec.Satisfies" in text
    r = check_lean(text)
    assert r["success"], r.get("error", "")[:1500]


@pytest.mark.slow
@pytest.mark.parametrize("case", FAILED_L2, ids=_id)
def test_replay_a_failed_implementation_is_still_rejected(case):
    """The stored failing code, with PO3 stated by the harness, does not check (no false negative
    was recorded as a failure by accident of the run)."""
    rep, e = case
    spec = corpus.l0_specs(rep)[e["id"]]["lean_predicate"]
    locked = C.strip_examples(spec) + "\n\n" + e["l1"]["code"]
    for x in e["l2"]:
        if not x["success"] and x["code"] and re.search(rf"^def {x['contract']}Impl\b", x["code"], re.M):
            code = x["code"]
            if f"theorem {x['contract']}Impl_ok" not in code:
                code += "\n\n" + po.theorem(po.po3_statement(x["contract"], x["contract"] + "Impl"),
                                             f"discharge_po3 [{x['contract']}, {x['contract']}Impl]")
            assert not check_lean(locked + "\n\n" + code)["success"], (e["id"], x["contract"])


@pytest.mark.slow
@pytest.mark.parametrize("case", VERIFIED[:8], ids=_id)
def test_mr_a_verified_file_under_renaming_sorry_and_a_broken_theorem(case):
    rep, e = case
    text = corpus.lean_path(rep, e["id"]).read_text(encoding="utf-8")
    # 1. padding with comments and blank lines changes nothing
    assert check_lean("-- note\n\n" + text.replace("\n\n", "\n\n-- pad\n\n"))["success"]
    # 2. the end-to-end proof replaced by `sorry` is not a proof
    cut = text.index("theorem system_ok")
    stmt = text[cut:].split(":=")[0]
    assert not check_lean(text[:cut] + stmt + ":= by\n  sorry\n")["success"]
    # 3. claiming the implementation meets a contract with an unsatisfiable `post` must fail
    impl = re.search(r"Spec\.Satisfies (.+?) :=", text[cut:]).group(1)
    false_claim = (f"\ndef Never : Contract Input Output := {{ pre := fun _ => True, post := fun _ _ => False }}\n"
                   f"theorem never_ok : Never.Satisfies {impl} := by\n  discharge_po3 [Never]\n")
    assert not check_lean(text + false_claim)["success"]
