# Per-spec L1 architect (chain path: main.py --until chain, e2e_l1l2.py): one L0 spec → two chained
# contracts Input → Mid → Output. The graph-based L1 used by --until arch lives in architect_agent.py.
"""L1: spec → component contracts. The model writes definitions; the harness states and proves PO1/PO2.

    single-step specs   (a data constraint, or a `post` that is one condition) are not split:
                        the architecture is `Spec` itself and PO2 is `Refines Spec Spec`
                        (`single_architecture`, no model call)
    everything else     the model writes `structure Mid` and two contracts. Its reply is
                        checked statically (chain_checks.static_check: shape, field
                        visibility, identity / copy-of-Spec components), then by Lean, then
                        the harness proves PO1 and PO2 itself (chain_checks.prove_obligations)
                        and, when one fails, names the conjunct that does not follow
"""
import hashlib
import re

import chain_checks as C
from agents.base import generate_verified

SYSTEM_PROMPT_ARCHITECT = """\
You are an architecture agent for ContractForge (Lean 4).

Given a system spec `Spec : Contract Input Output`, split it into EXACTLY TWO components
that run one after the other: the first turns `Input` into an intermediate record `Mid`,
the second turns `Mid` into `Output`. You write ONLY definitions. The harness then proves
PO1 (the first contract's `post` gives the second contract's `pre`) and PO2 (the two
together imply `Spec`) itself and tells you which part fails.

How to split: find ONE intermediate result that `Spec.post` depends on (a decision such as
"is the stock sufficient", a filtered list, a computed value). The first component
computes it and stores it in a `Mid` field; the second component states `Output` in terms
of `Mid`.

Rules:
- `Input`, `Output` and `Spec` are already in scope and LOCKED: never write them again.
  No `import`, no `theorem`, no `example`, no `sorry`.
- Write `structure Mid` (with `deriving DecidableEq, Repr`), then
  `def <A>Contract : Contract Input Mid where` and `def <B>Contract : Contract Mid Output where`,
  each with `pre := fun x => …` and `post := fun x y => …`.
- The second contract sees ONLY `Mid`. Every `Input` field it needs must be a field of
  `Mid`, copied by the first contract (`m.price = i.price`). Never write `i.…` in it.
- Both components must do real work. NOT allowed: a first `post` that only copies fields
  (`m.f = i.f ∧ …`), a second `post` that only copies fields (`o.f = m.f`), or a contract
  that is `Spec` again.
- The first `post` must relate every `Mid` field to `Input`: a copy (`m.f = i.f`) or a
  result (`m.ok = true ↔ <condition on i>`, `m.total = i.a * i.b`). It cannot claim a fact
  about the input that its `pre` does not ensure.
- The second `pre` may only assume what the first `post` guarantees for EVERY input. Never
  use it to select the success case (`m.ok = true`): decisions go in a `post` with `↔`.
- The first `pre` is the `pre` of `Spec`.
- Output ONLY Lean 4 code in one ```lean block.

Example 1. In scope:
  structure Input where price : Nat; qty : Nat; stock : Nat
  structure Output where accepted : Bool; total : Nat
  def Spec : Contract Input Output where
    pre  := fun i => i.qty > 0
    post := fun i o => (o.accepted = true ↔ i.qty ≤ i.stock) ∧ o.total = i.price * i.qty
Answer (the intermediate result is the stock decision):
```lean
structure Mid where
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
```

Example 2. In scope:
  structure Input where query : String; items : List String
  structure Output where results : List String; message : String
  def Spec : Contract Input Output where
    pre  := fun i => i.query ≠ ""
    post := fun i o => (∀ r ∈ o.results, r ∈ i.items) ∧ o.results.length ≤ 10 ∧
                       (o.message = "No results" ↔ o.results = [])
Answer (the intermediate result is the list of matches):
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

    state = {}

    def precheck(code: str) -> list:
        r = C.static_check(code, spec_code)
        state["static"] = r
        return r["problems"]

    def validate(code: str) -> list:
        r = C.prove_obligations(spec_code, code, state["static"]["facts"])
        state["proved"] = (code, r)
        return r["problems"]

    prompt = (f"These definitions are already in scope (LOCKED, do not repeat them):\n\n{spec_code}\n\n"
              "Split `Spec` into exactly two chained component contracts (`structure Mid` and two "
              "`def …Contract`). Definitions only.")
    result = generate_verified(prompt, SYSTEM_PROMPT_ARCHITECT, model, context=spec_code,
                               validate=validate, precheck=precheck, prepare=C.strip_theorems,
                               check_weakened=False, check_label="L1")
    result["mode"] = "chain"
    facts = C.static_check(result.get("code") or "", spec_code)["facts"] if result.get("code") else {}
    result["strength"] = facts.get("strength")
    result["contracts"] = [facts["a"], facts["b"]] if "a" in facts else extract_contracts(result.get("code") or "")
    if result["success"]:
        code, proved = state["proved"]
        result["code"] = code + "\n\n" + proved["theorems"]
    return result


def extract_contracts(arch_code: str) -> list:
    """Names of the component contracts defined by the architect."""
    return _CONTRACT_DEF.findall(arch_code)
