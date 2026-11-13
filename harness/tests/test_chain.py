"""Chain path (chain_checks.py, agents/chain_architect.py, agents/chain_coder.py,
chain_pipeline.py, chain_failures.py) on a toy order spec, with a scripted fake model.
Tests that run Lean are skipped if `lake` is missing."""
import shutil
import sys
import unittest
from pathlib import Path
from unittest import mock

HARNESS = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(HARNESS))
HAS_LEAN = shutil.which("lake") is not None

import chain_checks as C  # noqa: E402
from chain_failures import classify, root_cause  # noqa: E402

SPEC = """structure Input where
  price : Nat
  qty : Nat
  stock : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  total : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.qty > 0
  post := fun i o => (o.accepted = true ↔ i.qty ≤ i.stock) ∧ o.total = i.price * i.qty

example : Spec.pre { price := 2, qty := 3, stock := 5 } ∧
          Spec.post { price := 2, qty := 3, stock := 5 } { accepted := true, total := 6 } := by
  unfold Spec; decide
"""

GOOD = """structure Mid where
  price   : Nat
  qty     : Nat
  inStock : Bool
  deriving DecidableEq, Repr

def CheckStockContract : Contract Input Mid where
  pre  := fun i => i.qty > 0
  post := fun i m => m.price = i.price ∧ m.qty = i.qty ∧ (m.inStock = true ↔ i.qty ≤ i.stock)

def PriceOrderContract : Contract Mid Output where
  pre  := fun m => m.qty > 0
  post := fun m o => (o.accepted = true ↔ m.inStock = true) ∧ o.total = m.price * m.qty
"""

# First component only copies; the second is Spec over `m`.
IDENTITY = """structure Mid where
  price : Nat
  qty : Nat
  stock : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.qty > 0
  post := fun i m => m.price = i.price ∧ m.qty = i.qty ∧ m.stock = i.stock ∧ m.qty > 0

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.qty > 0
  post := fun m o => (o.accepted = true ↔ m.qty ≤ m.stock) ∧ o.total = m.price * m.qty
"""

# The second contract reads `stock`, which only Input has.
HIDDEN_FIELD = GOOD.replace("(o.accepted = true ↔ m.inStock = true)", "(o.accepted = true ↔ m.qty ≤ m.stock)")
USES_INPUT_VAR = GOOD.replace("(o.accepted = true ↔ m.inStock = true)", "(o.accepted = true ↔ i.qty ≤ i.stock)")
# The second contract assumes the success case.
PRE_SELECTS = GOOD.replace("pre  := fun m => m.qty > 0", "pre  := fun m => m.inStock = true")
# The first contract promises a fact about a copied field.
UNREALIZABLE = GOOD.replace("m.qty = i.qty ∧", "m.qty = i.qty ∧ m.qty ≤ 100 ∧")
# The stock decision never reaches Mid correctly.
LOSES_FACT = GOOD.replace("(m.inStock = true ↔ i.qty ≤ i.stock)", "(m.inStock = true ↔ i.qty > 0)")

IMPL_A = "def CheckStockContractImpl (i : Input) : Mid :=\n  { price := i.price, qty := i.qty, inStock := decide (i.qty ≤ i.stock) }"
IMPL_B = "def PriceOrderContractImpl (m : Mid) : Output :=\n  { accepted := m.inStock, total := m.price * m.qty }"
IMPL_B_WRONG = "def PriceOrderContractImpl (m : Mid) : Output :=\n  { accepted := m.inStock, total := m.price + m.qty }"
IMPL_B_BACKWARDS = "def PriceOrderContractImpl (o : Output) : Mid :=\n  { price := 0, qty := 0, inStock := o.accepted }"

SINGLE = """structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ i.raw.length = 9

example : Spec.pre { raw := "123456789" } ∧ Spec.post { raw := "123456789" } { valid := true } := by
  unfold Spec; decide
"""
# `o.accepted` is stated in terms of `o.total`: the total is an intermediate result.
STAGED = """structure Input where
  price : Nat
  qty : Nat
  budget : Nat
  deriving DecidableEq, Repr

structure Output where
  total : Nat
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.qty > 0
  post := fun i o => o.total = i.price * i.qty ∧ (o.accepted = true ↔ o.total ≤ i.budget)
"""
STAGED_GOOD = """structure Mid where
  total  : Nat
  budget : Nat
  deriving DecidableEq, Repr

def ComputeTotalContract : Contract Input Mid where
  pre  := fun i => i.qty > 0
  post := fun i m => m.total = i.price * i.qty ∧ m.budget = i.budget

def DecideOrderContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.total = m.total ∧ (o.accepted = true ↔ m.total ≤ m.budget)
"""
# The "decision" of the first component is the same for every input: an identity in disguise.
CONSTANT = GOOD.replace("(m.inStock = true ↔ i.qty ≤ i.stock)", "m.inStock = true")
IMPL_SINGLE = "def SpecImpl (i : Input) : Output :=\n  { valid := decide (i.raw.length = 9) }"


def fenced(code):
    return f"```lean\n{code}\n```"


class Scripted:
    """A model that returns the given replies in order (the last one again when it runs out)."""

    def __init__(self, replies):
        self.replies, self.prompts = list(replies), []

    def __call__(self, prompt, system=None, model=None, history=None, temperature=None):
        self.prompts.append(prompt)
        return fenced(self.replies.pop(0) if len(self.replies) > 1 else self.replies[0])


class TextChecks(unittest.TestCase):
    def test_conjuncts(self):
        self.assertEqual(C.conjuncts("(a ↔ b) ∧\n (∀ v ∈ o.r, v ∈ i.v ∧ p v) ∧ o.r.length ≤ 100"),
                         ["a ↔ b", "∀ v ∈ o.r, v ∈ i.v ∧ p v", "o.r.length ≤ 100"])
        self.assertEqual(len(C.conjuncts("o.valid = true ↔ (a) ∧ (b)")), 1)   # ∧ binds tighter than ↔
        self.assertEqual(C.conjuncts("x ∧ ∀ y ∈ l, p y ∧ q y"), ["x", "∀ y ∈ l, p y ∧ q y"])
        self.assertEqual(C.conjuncts("True"), [])

    def test_single_step(self):
        # two independent conditions (each one output field from the input): not stages
        self.assertIn("no intermediate result", C.single_step(SPEC, "requirement"))
        self.assertIsNone(C.single_step(STAGED, "requirement"))
        self.assertEqual([fs for _, fs in C.intermediate_results(STAGED)], [["accepted", "total"]])
        self.assertEqual(C.static_check(STAGED_GOOD, STAGED)["problems"], [])
        self.assertIn("single condition", C.single_step(SINGLE, "requirement"))
        self.assertIn("data constraint", C.single_step(SPEC, "data_constraint"))

    def test_good_architecture_and_strength(self):
        r = C.static_check(GOOD, SPEC)
        self.assertEqual(r["problems"], [])
        f = r["facts"]
        self.assertEqual((f["a"], f["b"], f["mid"]), ("CheckStockContract", "PriceOrderContract", "Mid"))
        self.assertEqual(f["carried"], {"price": "price", "qty": "qty"})
        self.assertEqual(f["derived"], ["inStock"])
        self.assertEqual(f["strength"]["score"], 5)

    def test_identity_and_copy_of_spec_rejected(self):
        r = C.static_check(IDENTITY, SPEC)
        text = " ".join(r["problems"])
        self.assertIn("`ValidateContract` is an identity", text)
        self.assertIn("`ComputeContract` is `Spec` again", text)
        self.assertFalse(r["facts"]["strength"]["first_does_work"])
        # a second contract that only copies
        r = C.static_check(GOOD.replace("(o.accepted = true ↔ m.inStock = true) ∧ o.total = m.price * m.qty",
                                        "o.accepted = m.inStock ∧ o.total = m.price"), SPEC)
        self.assertIn("`PriceOrderContract` is an identity", " ".join(r["problems"]))

    def test_visibility_names_the_field(self):
        p = " ".join(C.static_check(HIDDEN_FIELD, SPEC)["problems"])
        self.assertIn("reads `m.stock`", p)
        self.assertIn("Add `stock : Nat` to `structure Mid`", p)
        self.assertIn("`m.stock = i.stock` to the `post` of `CheckStockContract`", p)
        p = " ".join(C.static_check(USES_INPUT_VAR, SPEC)["problems"])
        self.assertIn("uses `i.stock`, but `i` is not one of its variables", p)

    def test_shape(self):
        one = GOOD.split("def PriceOrderContract")[0]
        self.assertIn("exactly two contracts", " ".join(C.static_check(one, SPEC)["problems"]))
        same = GOOD.replace("Contract Mid Output", "Contract Input Output")
        self.assertIn("types must chain", " ".join(C.static_check(same, SPEC)["problems"]))
        self.assertIn("`sorry` is not allowed", " ".join(C.static_check(GOOD + "\n-- x\ndef y := sorry", SPEC)["problems"]))

    def test_strip_theorems(self):
        code = GOOD + "\ntheorem po1 : True := by\n  trivial\n\nexample : True := trivial\n"
        self.assertEqual(C.strip_theorems(code), GOOD.strip())

    def test_classify(self):
        self.assertEqual(classify("static: `B` reads `m.x`, but `Mid` has no field `x` (…)"), "visibility")
        self.assertEqual(classify("static: `A` is an identity: its `post` only copies"), "identity")
        self.assertEqual(classify("L1: PO1 fails: `B` assumes more"), "po1")
        self.assertEqual(classify("L1: `A` computes nothing: for every input"), "identity")
        self.assertEqual(classify("static: the record `BImpl` returns does not match `structure Output`: `ok` is"),
                         "unknown-field")
        self.assertEqual(classify("L1: `A` cannot guarantee `m.q ≤ 9`: …"), "unrealizable")
        self.assertEqual(classify("L2: PO3 fails: for an input"), "po3")
        self.assertEqual(classify("static: `XImpl` has type `Mid → Input`, but `X : Contract Input Mid`"), "signature")
        self.assertEqual(classify("<generated>:3:1: error: 'Input' has already been declared"), "redeclared")
        self.assertEqual(classify("<generated>:3:1: error: Unknown identifier `i.query`"), "unknown-name")
        self.assertEqual(classify("<generated>:3:1: error: unsolved goals\n⊢ False"), "proof")
        self.assertEqual(classify("truncated: the reply was cut off"), "truncated")
        self.assertIsNone(classify(""))

    def test_root_cause_of_unimplementable_contract(self):
        e = {"l1": {"success": True, "mode": "chain", "code": UNREALIZABLE},
             "l2": [{"contract": "CheckStockContract", "success": False},
                    {"contract": "PriceOrderContract", "success": True}]}
        self.assertIn("not implementable", root_cause(e))
        e["l1"]["code"] = GOOD
        self.assertIsNone(root_cause(e))


@unittest.skipUnless(HAS_LEAN, "needs lake")
class LeanChecks(unittest.TestCase):
    def obligations(self, code):
        st = C.static_check(code, SPEC)
        self.assertEqual(st["problems"], [])
        return C.prove_obligations(SPEC, code, st["facts"])

    def test_good_architecture_is_proved_by_the_harness(self):
        r = self.obligations(GOOD)
        self.assertEqual(r["problems"], [])
        self.assertEqual(r["proved"], {"po1": True, "po2": True})
        self.assertIn("theorem po1 : Contract.Compatible CheckStockContract PriceOrderContract", r["theorems"])
        self.assertIn("theorem po2 : Contract.Refines (CheckStockContract.seq PriceOrderContract) Spec", r["theorems"])

    def test_po1_repair_drops_the_unguaranteed_assumption(self):
        r = self.obligations(PRE_SELECTS)
        self.assertEqual(r["problems"], [])
        self.assertEqual(r["proved"], {"po1": True, "po2": True})
        self.assertIn("removed from `PriceOrderContract.pre`", r["repairs"][0])
        self.assertIn("`m.inStock = true`", r["repairs"][0])
        fixed = {c.name: c for c in C.parse_contracts(r["code"])}["PriceOrderContract"]
        self.assertEqual(fixed.pre, "True")
        from lean_runner import check_lean
        self.assertTrue(check_lean(C.strip_examples(SPEC) + "\n\n" + r["code"] + "\n\n" + r["theorems"])["success"])
        # only the part that does not follow is removed
        both = GOOD.replace("pre  := fun m => m.qty > 0", "pre  := fun m => m.qty > 0 ∧ m.inStock = true")
        r = self.obligations(both)
        fixed = {c.name: c for c in C.parse_contracts(r["code"])}["PriceOrderContract"]
        self.assertEqual(fixed.pre, "(m.qty > 0)")

    def test_constant_result_is_rejected(self):
        r = self.obligations(CONSTANT)
        self.assertEqual(r["constant"], ["inStock"])
        self.assertIn("`CheckStockContract` computes nothing", " ".join(r["problems"]))
        self.assertEqual(r["theorems"], "")
        good = self.obligations(GOOD)
        self.assertEqual((good["constant"], good["results"]), ([], ["inStock"]))
        # a copy and a constant inside one `↔` condition (seen in the Qwen runs)
        hidden = GOOD.replace("m.price = i.price ∧ m.qty = i.qty ∧ (m.inStock = true ↔ i.qty ≤ i.stock)",
                              "m.price = i.price ∧ (m.qty = i.qty ∧ m.inStock = true ↔ i.qty > 0)")
        r = self.obligations(hidden)
        self.assertEqual((r["constant"], r["results"]), (["inStock"], []))
        self.assertIn("`m.qty` is a copy of an `Input` field", " ".join(r["problems"]))
        # `m.ok = true ↔ <the precondition>` is constant too
        self.assertEqual(self.obligations(LOSES_FACT)["constant"], ["inStock"])

    def test_trivial_witness_flags_a_weak_spec(self):
        weak = SINGLE.replace("o.valid = true ↔ i.raw.length = 9", "o.valid = true → i.raw.length ≤ 100 ∨ True")
        self.assertIsNotNone(C.trivial_witness(weak))
        self.assertIsNone(C.trivial_witness(SINGLE))
        self.assertIsNone(C.trivial_witness(SPEC))
        copy = STAGED.replace("o.total = i.price * i.qty ∧ (o.accepted = true ↔ o.total ≤ i.budget)",
                              "o.total = i.price ∧ o.accepted = true")
        self.assertEqual(C.trivial_witness(copy), "{ total := x.price, accepted := true }")

    def test_po2_names_the_lost_conjunct(self):
        r = self.obligations(LOSES_FACT)
        self.assertFalse(r["proved"]["po2"])
        p = " ".join(r["problems"])
        self.assertIn("PO2 fails", p)
        self.assertIn("`o.accepted = true ↔ i.qty ≤ i.stock`", p)
        self.assertNotIn("`o.total = i.price * i.qty`", p)

    def test_unrealizable_claim(self):
        r = self.obligations(UNREALIZABLE)
        p = " ".join(r["problems"])
        self.assertIn("cannot guarantee `m.qty ≤ 100`", p)
        self.assertIn("`i.qty ≤ 100`", p)
        # a restated precondition is fine
        ok = GOOD.replace("m.qty = i.qty ∧", "m.qty = i.qty ∧ m.qty > 0 ∧")
        self.assertEqual(self.obligations(ok)["problems"], [])

    def test_po_tactics_take_the_middle_value_apart(self):
        from lean_runner import check_lean
        ctx = C.strip_examples(SPEC) + "\n\n" + GOOD
        names = "CheckStockContract, PriceOrderContract, Spec"
        po2 = f"theorem po2 : Contract.Refines (CheckStockContract.seq PriceOrderContract) Spec := by\n  "
        self.assertTrue(check_lean(ctx + "\n\n" + po2 + f"discharge_po2 [{names}]")["success"])
        from agents.autoprove import _scripts
        self.assertEqual(_scripts(names, " Contract.Refines (A.seq B) Spec ")[0], f"discharge_po2 [{names}]")


@unittest.skipUnless(HAS_LEAN, "needs lake")
class Pipeline(unittest.TestCase):
    def run_entry(self, spec, replies, kind="requirement", **kw):
        import agents.base as base
        import chain_pipeline
        model = Scripted(replies)
        r = {"id": "T-1", "kind": kind, "requirement_text": "toy", "lean_predicate": spec}
        with mock.patch.object(base, "call_llm", model), mock.patch.object(base, "MAX_RETRIES", 3):
            return chain_pipeline.run_entry(r, "fake", **kw), model

    def test_end_to_end_two_components(self):
        import agents.base as base
        import chain_pipeline
        r = {"id": "T-1", "kind": "requirement", "requirement_text": "toy", "lean_predicate": SPEC}
        replies = iter([GOOD + "\ntheorem po1 : False := by\n  sorry\n", IMPL_A, IMPL_B])
        with mock.patch.object(base, "call_llm", lambda *a, **k: fenced(next(replies))):
            e = chain_pipeline.run_entry(r, "fake", split="always")
        self.assertTrue(e["l1"]["success"], e["l1"]["error"])
        self.assertEqual(e["l1"]["mode"], "chain")
        self.assertEqual(e["l1"]["contracts"], ["CheckStockContract", "PriceOrderContract"])
        self.assertNotIn("sorry", e["l1"]["code"])         # the model's theorem was dropped
        self.assertIn("discharge_po2", e["l1"]["code"])     # the harness wrote its own
        self.assertEqual([x["success"] for x in e["l2"]], [True, True])
        self.assertIn("Spec.Satisfies (PriceOrderContractImpl ∘ CheckStockContractImpl)", e["system_theorem"])
        self.assertTrue(e["full_check"])
        from lean_runner import check_lean
        self.assertTrue(check_lean(chain_pipeline.lean_file(r, e))["success"])

    def test_repair_gets_the_named_problem(self):
        import agents.base as base
        import agents.chain_architect as arch
        model = Scripted([HIDDEN_FIELD, IDENTITY, GOOD])
        with mock.patch.object(base, "call_llm", model):
            r = arch.run_architect(SPEC, "fake", kind="requirement", split="always")
        self.assertTrue(r["success"])
        self.assertEqual(r["attempts"], 3)
        self.assertEqual([x["stage"] for x in r["log"]], ["static", "static", "ok"])
        self.assertIn("Add `stock : Nat` to `structure Mid`", model.prompts[1])
        self.assertIn("is an identity", model.prompts[2])

    def test_staged_spec_is_split_and_told_the_intermediate(self):
        import agents.base as base
        import agents.chain_architect as arch
        model = Scripted([STAGED_GOOD])
        with mock.patch.object(base, "call_llm", model):
            r = arch.run_architect(STAGED, "fake", kind="requirement")
        self.assertTrue(r["success"], r.get("error"))
        self.assertEqual(r["mode"], "chain")
        self.assertIn("relates the output fields `accepted`, `total`", model.prompts[0])
        self.assertEqual((r["strength"]["score"], r["strength"]["of"]), (5, 6))   # no interface assumption

    def test_two_independent_conditions_are_one_component(self):
        impl = "def SpecImpl (i : Input) : Output :=\n  { accepted := decide (i.qty ≤ i.stock), total := i.price * i.qty }"
        e, model = self.run_entry(SPEC, [impl])
        self.assertEqual(e["l1"]["mode"], "single")
        self.assertIn("no intermediate result", e["l1"]["why_single"])
        self.assertEqual(e["spec_check"], {"trivial": False})
        self.assertTrue(e["full_check"])

    def test_dropping_an_assumption_is_not_weakening(self):
        import agents.base as base
        import agents.chain_architect as arch
        fixed = PRE_SELECTS.replace("pre  := fun m => m.inStock = true", "pre  := fun _ => True")
        model = Scripted([PRE_SELECTS, fixed])
        with mock.patch.object(base, "call_llm", model):
            r = arch.run_architect(SPEC, "fake", kind="requirement", split="always")
        self.assertTrue(r["success"], r.get("error"))
        # the harness removes the unguaranteed assumption itself: no second model call
        self.assertEqual([x["stage"] for x in r["log"]], ["ok"])
        self.assertIn("`m.inStock = true`", r["repairs"][0])
        self.assertIn("pre  := fun m => True", r["code"])
        self.assertFalse(r["strength"]["interface_assumption"])
        self.assertTrue(r["strength"]["first_result_depends_on_input"])

    def test_single_step_spec_is_not_split(self):
        e, model = self.run_entry(SINGLE, [IMPL_SINGLE])
        self.assertEqual(e["l1"]["mode"], "single")
        self.assertEqual(e["l1"]["attempts"], 0)
        self.assertEqual(e["l1"]["contracts"], ["Spec"])
        self.assertEqual(len(model.prompts), 1)             # only the coder was asked
        self.assertIn("Spec.Satisfies SpecImpl", e["system_theorem"])
        self.assertTrue(e["full_check"])

    def test_failed_split_and_fallback(self):
        e, _ = self.run_entry(SPEC, [IDENTITY], split="always")
        self.assertFalse(e["l1"]["success"])
        self.assertEqual(e["l1"]["error_class"], "identity")
        self.assertEqual(e["l2"], [])
        impl = "def SpecImpl (i : Input) : Output :=\n  { accepted := decide (i.qty ≤ i.stock), total := i.price * i.qty }"
        e, _ = self.run_entry(SPEC, [IDENTITY, IDENTITY, IDENTITY, impl], fallback_single=True, split="always")
        self.assertEqual(e["l1"]["mode"], "single-fallback")
        self.assertEqual(e["l1"]["failed_split"]["error_class"], "identity")
        self.assertTrue(e["full_check"])

    def test_run_writes_files_resumes_and_summarizes_repetitions(self):
        """chain_pipeline.run on an L0 folder (as main.py --until chain does per repetition),
        then evaluation/summarize_e2e.py over two repetitions."""
        import json
        import tempfile
        import agents.base as base
        import chain_pipeline
        sys.path.insert(0, str(HARNESS.parent / "evaluation"))
        import summarize_e2e
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            l0 = tmp / "l0"
            l0.mkdir()
            results = [{"id": "R/1", "kind": "requirement", "requirement_text": "order", "lean_predicate": SPEC,
                        "checked": True},
                       {"id": "DD-x", "kind": "data_constraint", "requirement_text": "nine chars",
                        "lean_predicate": SINGLE, "checked": True},
                       {"id": "R/2", "kind": "requirement", "requirement_text": "unchecked", "lean_predicate": SPEC,
                        "checked": False}]
            (l0 / "specs.json").write_text(json.dumps({"results": results}))
            (l0 / "review.json").write_text(json.dumps({"R/1": {"decision": "accept"}, "DD-x": {"decision": "accept"},
                                                        "R/2": {"decision": "accept"}}))
            run = tmp / "run"
            # rep1: everything works. rep2: the split of R/1 fails (identity every time).
            for rep, replies in (("rep1", [GOOD, IMPL_A, IMPL_B, IMPL_SINGLE]),
                                 ("rep2", [IDENTITY, IDENTITY, IDENTITY, IMPL_SINGLE])):
                with mock.patch.object(base, "call_llm", Scripted(replies)), mock.patch.object(base, "MAX_RETRIES", 3), \
                        mock.patch.object(C, "intermediate_results",          # treat the order spec as staged
                                          lambda s: [("x", ["accepted", "total"])] if "stock" in s else []):
                    out = chain_pipeline.run(l0, run / rep, "fake", meta={"seed": 42})
                self.assertEqual([e["id"] for e in out], ["R/1", "DD-x"])     # R/2 was not checked
            rep1 = json.loads((run / "rep1" / "l1l2.json").read_text())
            self.assertEqual([e["full_check"] for e in rep1], [True, True])
            self.assertEqual([e["l1"]["mode"] for e in rep1], ["chain", "single"])
            self.assertEqual(rep1[0]["l1"]["strength"]["score"], 6)
            self.assertEqual([e["spec_check"]["trivial"] for e in rep1], [False, False])
            self.assertIn("theorem system_ok", (run / "rep1" / "l1l2" / "R_1.lean").read_text())
            self.assertTrue((run / "rep1" / "chain_meta.json").exists())
            # resume keeps finished records and asks the model nothing
            with mock.patch.object(base, "call_llm", lambda *a, **k: self.fail("resume must not call the model")):
                again = chain_pipeline.run(l0, run / "rep1", "fake", resume=True)
            self.assertEqual(again, rep1)
            reps = summarize_e2e.load_run(run)
            self.assertEqual([name for name, _ in reps], ["rep1", "rep2"])
            ms = [summarize_e2e.metrics(d, {}) for _, d in reps]
            self.assertEqual([m["end to end"] for m in ms], [2, 1])
            self.assertEqual([m["L1 chain (two components)"] for m in ms], [1, 0])
            self.assertEqual([m["L1 single (not split)"] for m in ms], [1, 1])
            self.assertEqual(summarize_e2e.failures(reps[1][1])["l1"], {"identity": 1})
            text = summarize_e2e.report(run)
            self.assertIn("| end to end | 1.50 (1–2) |", text)
            self.assertIn("| identity | 0.50 (0–1) |", text)
            self.assertIn("Not end to end in every repetition (0)", text)

    def test_coder_wrong_direction_and_wrong_value(self):
        import agents.base as base
        from agents.chain_coder import run_coder
        locked = SPEC + "\n\n" + GOOD
        model = Scripted([IMPL_B_BACKWARDS, IMPL_B_WRONG, IMPL_B])
        with mock.patch.object(base, "call_llm", model):
            r = run_coder("PriceOrderContract", locked, "fake")
        self.assertTrue(r["success"], r.get("error"))
        self.assertEqual([x["stage"] for x in r["log"]], ["static", "check", "ok"])
        self.assertIn("needs `Mid → Output`", model.prompts[1])
        self.assertIn("`o.total = m.price * m.qty`", model.prompts[2])   # the conjunct that fails
        self.assertNotIn("`o.accepted = true ↔ m.inStock = true`", model.prompts[2])
        self.assertIn("theorem PriceOrderContractImpl_ok : PriceOrderContract.Satisfies PriceOrderContractImpl", r["code"])
        self.assertIn("`Output` has exactly these fields: `accepted : Bool`, `total : Nat`", model.prompts[0])

    def test_coder_is_told_the_fields_of_the_result(self):
        """A `Mid` field copied into `Output` is reported with the field list, before Lean."""
        import agents.base as base
        from agents.chain_coder import record_problems, run_coder
        wrong = "def PriceOrderContractImpl (x : Mid) : Output :=\n  { accepted := x.inStock, total := x.price * x.qty, qty := x.qty }"
        model = Scripted([wrong, IMPL_B])
        with mock.patch.object(base, "call_llm", model):
            r = run_coder("PriceOrderContract", SPEC + "\n\n" + GOOD, "fake")
        self.assertTrue(r["success"], r.get("error"))
        self.assertEqual([x["stage"] for x in r["log"]], ["static", "ok"])
        self.assertIn("`qty` is not a field of `Output` (`qty` belongs to `Mid`", model.prompts[1])
        self.assertIn("Write `{ accepted := …, total := … }` and nothing else.", model.prompts[1])
        fields = {"Mid": {"a": "Nat"}, "Output": {"a": "Nat", "b": "Nat"}}
        p = record_problems("def FImpl (x : Mid) : Output :=\n  { a := 1, a := 2 }", "FImpl", "Mid", "Output", fields)
        self.assertIn("`a` is set more than once; missing: `b`", p[0])
        nested = "def FImpl (x : Mid) : Output :=\n  if x.a = 0 then { a := 0, b := 0 } else { a := (fun y => y) 1, b := 2 }"
        self.assertEqual(record_problems(nested, "FImpl", "Mid", "Output", fields), [])


if __name__ == "__main__":
    unittest.main()
