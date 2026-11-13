# Per-spec L1 architect (chain path: main.py --until chain, e2e_l1l2.py): one L0 spec → two chained
# contracts Input → Mid → Output. The graph-based L1 used by --until arch lives in architect_agent.py.
"""L1: spec → component contracts. The model writes definitions; the harness states and proves PO1/PO2.

    single-step specs   (a data constraint, or a `post` with no intermediate result: no output
                        field is stated in terms of another) are not split: the
                        architecture is `Spec` itself and PO2 is `Refines Spec Spec`
                        (`single_architecture`, no model call)
    everything else     the model writes `structure Mid` and two contracts. Its reply is
                        checked statically (chain_checks.static_check: shape, field
                        visibility, identity / copy-of-Spec components), then by Lean, then
                        the harness proves PO1 and PO2 itself (chain_checks.prove_obligations)
                        and, when one fails, names the conjunct that does not follow. It
                        also rejects a first component whose result is constant, and removes
                        from the second `pre` what the first `post` does not give (`repairs`)
"""
import hashlib
import os
import re

import chain_checks as C
from agents.base import generate_verified
from chain_failures import classify

SYSTEM_PROMPT_ARCHITECT = """\
You are an architecture agent for ContractForge (Lean 4).

Given a system spec `Spec : Contract Input Output`, split it into EXACTLY TWO components
that run one after the other: the first turns `Input` into an intermediate record `Mid`,
the second turns `Mid` into `Output`. You write ONLY definitions. The harness then proves
PO1 (the first contract's `post` gives the second contract's `pre`) and PO2 (the two
together imply `Spec`) itself and tells you which part fails.

How to split: `Spec.post` states one output in terms of another (you are told which). The
one that the others depend on is the INTERMEDIATE RESULT (a computed value, a filtered
list). The first component computes it from `Input` and stores it in a `Mid` field; the
second component states `Output` in terms of `Mid`.

Rules:
- `Input`, `Output` and `Spec` are already in scope and LOCKED: never write them again.
  No `import`, no `theorem`, no `example`, no `sorry`.
- Write `structure Mid` (with `deriving DecidableEq, Repr`), then
  `def <A>Contract : Contract Input Mid where` and `def <B>Contract : Contract Mid Output where`,
  each with `pre := fun x => …` and `post := fun x y => …`.
- The second contract sees ONLY `Mid`. Every `Input` field it needs must be a field of
  `Mid`, copied by the first contract (`m.budget = i.budget`). Never write `i.…` in it.
- Both components must do real work. NOT allowed: a first `post` that only copies fields
  (`m.f = i.f ∧ …`), a second `post` that only copies fields (`o.f = m.f`), or a contract
  that is `Spec` again.
- The intermediate result must depend on the input. NOT allowed: a `Mid` field that is
  always the same, such as `m.ok = true`, `m.done = false`, or `m.ok = true ↔ P` where `P`
  is the precondition.
- The first `post` must relate every `Mid` field to `Input`: a copy (`m.f = i.f`) or a
  result (`m.total = i.a * i.b`, `∀ r ∈ m.found, r ∈ i.items`). It cannot claim a fact
  about the input that its `pre` does not ensure.
- The second `pre` is `fun _ => True`, or only facts the first `post` gives for EVERY
  input. Never a condition that selects the success case.
- The first `pre` is the `pre` of `Spec`.
- Output ONLY Lean 4 code in one ```lean block.

Example 1. In scope:
  structure Input where price : Nat; qty : Nat; budget : Nat
  structure Output where total : Nat; accepted : Bool
  def Spec : Contract Input Output where
    pre  := fun i => i.qty > 0
    post := fun i o => o.total = i.price * i.qty ∧ (o.accepted = true ↔ o.total ≤ i.budget)
`o.accepted` is stated in terms of `o.total`: the total is the intermediate result.
```lean
structure Mid where
  total  : Nat
  budget : Nat
  deriving DecidableEq, Repr

def ComputeTotalContract : Contract Input Mid where
  pre  := fun i => i.qty > 0
  post := fun i m => m.total = i.price * i.qty ∧ m.budget = i.budget

def DecideOrderContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.total = m.total ∧ (o.accepted = true ↔ m.total ≤ m.budget)
```

Example 2. In scope:
  structure Input where query : String; items : List String
  structure Output where results : List String; message : String
  def Spec : Contract Input Output where
    pre  := fun i => i.query ≠ ""
    post := fun i o => (∀ r ∈ o.results, r ∈ i.items) ∧ o.results.length ≤ 10 ∧
                       (o.message = "No results" ↔ o.results = [])
`o.message` is stated in terms of `o.results`: the list of matches is the intermediate result.
```lean
structure Mid where
  found : List String
  deriving DecidableEq, Repr

def FindMatchesContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => ∀ r ∈ m.found, r ∈ i.items

def ShowResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (∀ r ∈ o.results, r ∈ m.found) ∧ o.results.length ≤ 10 ∧
                     (o.message = "No results" ↔ o.results = [])
```
"""

# v11 (issue 1): Input fields the second contract reads are added to Mid by the harness.
CARRY_FIELDS = os.getenv("CF_CARRY_FIELDS", "1") == "1"
# v11 (issue 2): identity splits this many times → stop; the pipeline falls back to one component.
IDENTITY_STOP = int(os.getenv("CF_IDENTITY_STOP", "2"))
NOT_DECOMPOSABLE = "not decomposable: every split made one component an identity"
_CONTRACT_DEF = re.compile(r"^def\s+(\w+Contract)\b", re.MULTILINE)
SINGLE_PO2 = ("theorem po2 : Contract.Refines Spec Spec :=\n"
              "  ⟨fun _ h => h, fun _ _ _ h => h⟩")


def prompt_hash() -> str:
    return hashlib.sha256(SYSTEM_PROMPT_ARCHITECT.encode("utf-8")).hexdigest()[:12]


def single_architecture(reason: str) -> dict:
    """The architecture of a spec that is not split: its one component is `Spec`."""
    return {"success": True, "mode": "single", "why_single": reason, "attempts": 0, "log": [],
            "code": f"-- not split ({reason}): the one component is `Spec` itself\n{SINGLE_PO2}",
            "contracts": ["Spec"], "strength": None}


def run_architect(spec_code: str, model: str, kind: str = None, split: str = "auto") -> dict:
    """`split`: "auto" (single-step specs are not split), "always", "never".

    Returns generate_verified's result plus `mode` ("single" | "chain"), `contracts` (names
    in chain order), `strength` (chain_checks facts) and `checks` (what each attempt failed)."""
    reason = "requested" if split == "never" else (C.single_step(spec_code, kind) if split == "auto" else None)
    if reason:
        return single_architecture(reason)

    state = {"carried": []}

    def prepare(code: str) -> str:
        code = C.strip_theorems(code)
        if not CARRY_FIELDS:
            return code
        code, added = C.carry_input_fields(code, spec_code)
        if added:
            state["carried"] = list(dict.fromkeys(state["carried"] + added))
        return code

    def precheck(code: str) -> list:
        r = C.static_check(code, spec_code)
        state["static"] = r
        return r["problems"]

    def validate(code: str) -> list:
        r = C.prove_obligations(spec_code, code, state["static"]["facts"])
        state["proved"] = (code, r)
        return r["problems"]

    hint = ""
    inter = C.intermediate_results(spec_code)
    if inter:
        cond, fs = inter[0]
        hint = (f"In `Spec.post`, the condition `{' '.join(cond.split())}` relates the output fields "
                + ", ".join(f"`{f}`" for f in fs) + ": one of them is the intermediate result that the "
                "first component computes.\n\n")
    prompt = (f"These definitions are already in scope (LOCKED, do not repeat them):\n\n{spec_code}\n\n{hint}"
              "Split `Spec` into exactly two chained component contracts (`structure Mid` and two "
              "`def …Contract`). Definitions only.")
    identity = {"n": 0}

    def stop_on(error: str):
        """v11 (issue 2): a split whose component only copies, twice, means the spec has no
        real intermediate result: stop and report it as not decomposable."""
        if classify(error) == "identity":
            identity["n"] += 1
            if identity["n"] >= IDENTITY_STOP:
                return NOT_DECOMPOSABLE
        return None

    result = generate_verified(prompt, SYSTEM_PROMPT_ARCHITECT, model, context=spec_code,
                               validate=validate, precheck=precheck, prepare=prepare,
                               check_weakened=False, check_label="L1", stop_on=stop_on)
    result["mode"] = "chain"
    facts = C.static_check(result.get("code") or "", spec_code)["facts"] if result.get("code") else {}
    result["strength"] = facts.get("strength")
    result["contracts"] = [facts["a"], facts["b"]] if "a" in facts else extract_contracts(result.get("code") or "")
    result["repairs"] = []
    if state["carried"]:
        result["carried_by_harness"] = state["carried"]
    if result["success"]:
        _, proved = state["proved"]
        result["repairs"] = proved["repairs"]
        if proved["repairs"]:        # the second `pre` changed: the record describes what was proved
            result["strength"] = C.static_check(proved["code"], spec_code)["facts"].get("strength")
        if result["strength"]:
            st = result["strength"]
            st["first_result_depends_on_input"] = bool(proved["results"])
            st["score"] = sum(v for k, v in st.items() if k not in ("score", "of"))
            st["of"] = 6
        result["code"] = proved["code"] + "\n\n" + proved["theorems"]
    return result


def extract_contracts(arch_code: str) -> list:
    """Names of the component contracts defined by the architect."""
    return _CONTRACT_DEF.findall(arch_code)
