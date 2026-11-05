"""L2: one locked architecture context → component implementations + automated PO3 proofs."""
import re
from typing import Callable, Dict, List, Optional, Sequence

import code_lean as CL
from agents.base import generate_verified
from lean_runner import check_lean

WORKED_EXAMPLE = """\
Example (a toy shop, not your system).
Component `Stock` owns operations `OP-restock` and `OP-sell`.
For `OP-restock`:
```lean
def Stock_impl_op_restock (i : L0_op_restock.Input) : L0_op_restock.Output :=
  { stock := i.stock + i.amount }

theorem Stock_impl_op_restock_ok : ∀ i : L0_op_restock.Input, Stock_pre_op_restock i → Stock_post_op_restock i (Stock_impl_op_restock i) := by
  intro i hpre
  unfold Stock_post_op_restock Stock_impl_op_restock
  rfl
```

For `OP-sell`:
```lean
def Stock_impl_op_sell (i : L0_op_sell.Input) : L0_op_sell.Output :=
  { stock := i.stock - 1, sold := true }

theorem Stock_impl_op_sell_ok : ∀ i : L0_op_sell.Input, Stock_pre_op_sell i → Stock_post_op_sell i (Stock_impl_op_sell i) := by
  intro i hpre
  dsimp [Stock_post_op_sell, Stock_impl_op_sell, Stock_pre_op_sell] at *
  refine ⟨by omega, rfl⟩
```

For `OP-audit` owned by `Audit`:
```lean
def Audit_impl_op_audit (i : L0_op_audit.Input) : L0_op_audit.Output :=
  { ok := decide (i.stock ≤ 100) }

theorem Audit_impl_op_audit_ok : ∀ i : L0_op_audit.Input, Audit_pre_op_audit i → Audit_post_op_audit i (Audit_impl_op_audit i) := by
  intro i hpre
  unfold Audit_post_op_audit Audit_impl_op_audit
  simp
```
"""

SYSTEM_PROMPT_CODER = f"""\
You are a coding agent for ContractForge (Lean 4.29, Lean core only, no Mathlib).

Given a locked specification and contract, implement the operation function and prove that it satisfies
the contract's pre and post conditions.

For operation `<op>` owned by component `<C>`:
1. Implement the function:
   def <C>_impl_<op> (i : L0_<op>.Input) : L0_<op>.Output := …
2. Prove that it satisfies the contract:
   theorem <C>_impl_<op>_ok : ∀ i : L0_<op>.Input, <C>_pre_<op> i → <C>_post_<op> i (<C>_impl_<op> i) := by …

Rules:
- Output ONLY the implementation function and the proof theorem (plus any private helper defs you need)
  in ONE ```lean block. No imports, no open, no namespace, no duplicate declarations.
- Never use `sorry`, `admit`, `native_decide`, or `axiom`.
- The definitions and contracts are already in scope and LOCKED: do not modify them.
- Proof strategies: try `rfl`, `simp`, `omega`, or manual witness/intro steps.

{WORKED_EXAMPLE}
"""

_FORBIDDEN = re.compile(r"\b(sorry|admit|native_decide|axiom)\b")


def validate_op_code(comp: str, op: str) -> Callable[[str], List[str]]:
    """Validates that operation code defines the required function and lemma without sorry."""
    impl_name = CL.impl_op_name(comp, op)
    ok_name = CL.impl_op_ok_name(comp, op)
    impl_pat = re.compile(rf"\bdef\s+{re.escape(impl_name)}\b")
    ok_pat = re.compile(rf"\b(?:theorem|lemma)\s+{re.escape(ok_name)}\b")

    def _validate(code: str) -> List[str]:
        problems = []
        m = _FORBIDDEN.search(code)
        if m:
            problems.append(f"Forbidden proof-bypassing keyword `{m.group()}` is not allowed.")
        if not impl_pat.search(code):
            problems.append(f"Missing required implementation function `def {impl_name}`.")
        if not ok_pat.search(code):
            problems.append(f"Missing required proof theorem `theorem {ok_name}`.")
        return problems

    return _validate


def run_op_coder(comp: str, op: str, locked_context: str, model: str) -> dict:
    """Invokes generate_verified to implement an operation and prove its correctness lemma."""
    prompt = (
        f"Implement operation `{op}` for component `{comp}` and prove that it satisfies the contract.\n\n"
        f"Locked context in scope:\n```lean\n{locked_context}\n```\n\n"
        f"Required signatures to implement:\n"
        f"```lean\n"
        f"{CL.impl_op_sig(comp, op)}\n\n"
        f"{CL.impl_op_ok_statement(comp, op)}\n"
        f"```\n"
    )
    res = generate_verified(
        prompt=prompt,
        system=SYSTEM_PROMPT_CODER,
        model=model,
        context=locked_context,
        validate=validate_op_code(comp, op),
    )
    return {
        "op": op,
        "comp": comp,
        "success": res.get("success", False),
        "code": res.get("code", ""),
        "attempts": res.get("attempts", 0),
        "log": res.get("log", []),
        "error": res.get("error", ""),
    }


def run_component_coder(
    group: str,
    comp: str,
    owned: Sequence[str],
    all_ops: Sequence[str],
    locked_context: str,
    model: str,
    op_coder_fn: Optional[Callable] = None,
    skip_lean: bool = False,
) -> dict:
    """Coordinates code generation for all operations owned by `comp`, assembles the component dispatcher

    `<comp>Impl`, and verifies the PO3 theorem `<comp>Impl_ok`.
    """
    if op_coder_fn is None:
        op_coder_fn = run_op_coder

    sorted_owned = sorted(set(owned), key=CL.slug)
    ops_dict: Dict[str, dict] = {}
    failing_op = None

    for op in sorted_owned:
        op_res = op_coder_fn(comp, op, locked_context, model)
        ops_dict[op] = op_res
        if not op_res.get("success"):
            failing_op = op
            break

    if failing_op is not None:
        fail_err = ops_dict[failing_op].get("error", "unknown error")
        return {
            "component": comp,
            "code": "",
            "success": False,
            "proved": False,
            "ops": ops_dict,
            "error": f"Operation '{failing_op}' failed: {fail_err}",
        }

    parts = [ops_dict[op]["code"].strip() for op in sorted_owned if ops_dict[op].get("code")]
    parts.append(CL.component_impl_def(group, comp, sorted_owned, all_ops))
    parts.append(f"{CL.po3_statement(comp)} := {CL.auto_po3_proof(group, comp, sorted_owned, all_ops)}")
    full_code = "\n\n".join(parts) + "\n"

    if skip_lean:
        return {
            "component": comp,
            "code": full_code,
            "success": True,
            "proved": True,
            "ops": ops_dict,
        }

    check = check_lean(f"{locked_context}\n\n{full_code}" if locked_context else full_code)
    proved = check.get("success", False)
    return {
        "component": comp,
        "code": full_code,
        "success": proved,
        "proved": proved,
        "ops": ops_dict,
        "error": check.get("error", "") if not proved else "",
    }
