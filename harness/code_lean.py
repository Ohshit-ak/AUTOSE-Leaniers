"""L2 Lean text generator, written by the harness (no model). Deterministic: same inputs → same text.

In L1, `harness/arch_lean.py` writes deterministic Lean definitions for message types, system specs,
contracts, trace obligations, and PO1/PO2 proofs. In L2, this module plays the exact same role for
implementation:
  - Operation implementation signatures (`<C>_impl_<slug(op)>`)
  - Per-operation proof statements (`<C>_impl_<slug(op)>_ok`)
  - Component message dispatcher (`<C>Impl`)
  - Component PO3 statement (`<C>Impl_ok`)
  - Automated PO3 proof (`auto_po3_proof`)
  - Composite system implementation (`<group>SystemImpl`)
  - Instantiation theorem (`system_sound_<group>_inst`)
"""
from typing import Sequence

from arch_lean import camel, post_name, pre_name, slug, theorem

__all__ = [
    "slug",
    "camel",
    "pre_name",
    "post_name",
    "theorem",
    "impl_op_name",
    "impl_op_ok_name",
    "impl_op_sig",
    "impl_signatures",
    "impl_op_ok_statement",
    "component_impl_def",
    "po3_name",
    "po3_statement",
    "auto_po3_proof",
    "system_impl_name",
    "system_impl_expr",
    "system_impl_def",
    "system_sound_instantiation",
]


# ---------------------------------------------------------------------------
# Per-operation implementation names, signatures, and proof statements
# ---------------------------------------------------------------------------

def impl_op_name(comp: str, op: str) -> str:
    """Implementation function name for operation `op` in component `comp`: `<C>_impl_<slug(op)>`."""
    return f"{comp}_impl_{slug(op)}"


def impl_op_ok_name(comp: str, op: str) -> str:
    """Proof theorem name establishing that `<C>_impl_<op>` satisfies contract pre/post."""
    return f"{comp}_impl_{slug(op)}_ok"


def impl_op_sig(comp: str, op: str) -> str:
    """Signature template for an operation implementation:
    `def <C>_impl_<slug(op)> (i : L0_<slug(op)>.Input) : L0_<slug(op)>.Output := …`
    """
    s = slug(op)
    return f"def {impl_op_name(comp, op)} (i : L0_{s}.Input) : L0_{s}.Output := …"


def impl_signatures(comp: str, owned: Sequence[str]) -> str:
    """Signatures of all operations owned by `comp`, sorted by slug."""
    return "\n".join(impl_op_sig(comp, op) for op in sorted(owned, key=slug))


def impl_op_ok_statement(comp: str, op: str) -> str:
    """Statement establishing that `<C>_impl_<op>` satisfies `comp`'s pre and post condition."""
    s = slug(op)
    name = impl_op_ok_name(comp, op)
    pre = pre_name(comp, op)
    post = post_name(comp, op)
    impl = impl_op_name(comp, op)
    return f"theorem {name} : ∀ i : L0_{s}.Input, {pre} i → {post} i ({impl} i)"


# ---------------------------------------------------------------------------
# Component dispatcher and PO3 statement / automated proof
# ---------------------------------------------------------------------------

def component_impl_def(group: str, comp: str, owned: Sequence[str], all_ops: Sequence[str] = ()) -> str:
    """`<comp>Impl`: handles owned operations by calling their respective implementation functions,
    and passes any other message unchanged (`| m => m`). Owned operation branches are sorted
    alphabetically by `slug(op)`.
    """
    lines = [
        f"/-- Implementation of component {comp}: handles owned operations, passes others unchanged. -/",
        f"def {comp}Impl (m : {group}Msg) : {group}Msg :=",
        "  match m with",
    ]
    for op in sorted(owned, key=slug):
        s = slug(op)
        lines.append(f"  | .req_{s} i => .res_{s} ({impl_op_name(comp, op)} i)")
    lines.append("  | m => m")
    return "\n".join(lines)


def po3_name(comp: str) -> str:
    """PO3 theorem name: `<comp>Impl_ok`."""
    return f"{comp}Impl_ok"


def po3_statement(comp: str) -> str:
    """PO3 theorem statement: `theorem <comp>Impl_ok : <comp>Contract.Satisfies <comp>Impl`."""
    return f"theorem {po3_name(comp)} : {comp}Contract.Satisfies {comp}Impl"


def auto_po3_proof(group: str, comp: str, owned: Sequence[str], all_ops: Sequence[str]) -> str:
    """Generates an automated proof for PO3 (`<comp>Contract.Satisfies <comp>Impl`).

    Matches on message `m : <group>Msg`:
      - For owned requests: witness `<comp>_impl_<op> i`, identity response equality `rfl`,
        and `<comp>_impl_<op>_ok i hpre`.
      - For unowned requests: passes unchanged, post is `m = m` solved by `rfl`.
      - For responses: passes unchanged, post is `m = m` solved by `rfl`.

    All branches are sorted alphabetically by `slug(op)` for determinism.
    """
    owned_set = set(owned)
    full_all_ops = list(all_ops)
    for op in owned:
        if op not in full_all_ops:
            full_all_ops.append(op)

    sorted_owned = sorted(owned, key=slug)
    unowned = sorted([op for op in full_all_ops if op not in owned_set], key=slug)
    sorted_all = sorted(full_all_ops, key=slug)

    lines = ["by", "  intro m hpre", "  cases m with"]
    for op in sorted_owned:
        s = slug(op)
        lines.append(f"  | req_{s} i =>")
        lines.append(f"    exact ⟨{impl_op_name(comp, op)} i, rfl, {impl_op_ok_name(comp, op)} i hpre⟩")
    for op in unowned:
        s = slug(op)
        lines.append(f"  | req_{s} i => rfl")
    for op in sorted_all:
        s = slug(op)
        lines.append(f"  | res_{s} o => rfl")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Composite system implementation and soundness instantiation
# ---------------------------------------------------------------------------

def system_impl_name(group: str) -> str:
    """Composite system implementation name: `<group>SystemImpl`."""
    return f"{group}SystemImpl"


def system_impl_expr(comps: Sequence[str]) -> str:
    """Function composition expression matching the composition order in `arch_lean.system_sound_theorem`:
    For 1 component: `<comps[0]>Impl`
    For N > 1 components: `<comps[-1]>Impl ∘ ... ∘ <comps[0]>Impl`
    """
    if not comps:
        raise ValueError("comps must not be empty")
    impl = f"{comps[0]}Impl"
    for c in comps[1:]:
        impl = f"{c}Impl ∘ ({impl})" if " " in impl else f"{c}Impl ∘ {impl}"
    return impl


def system_impl_def(group: str, comps: Sequence[str]) -> str:
    """`def <group>SystemImpl : <group>Msg → <group>Msg := <system_impl_expr>`."""
    expr = system_impl_expr(comps)
    return f"def {system_impl_name(group)} : {group}Msg → {group}Msg := {expr}"


def system_sound_instantiation(group: str, comps: Sequence[str]) -> str:
    """Instantiates `system_sound_<group>` with `<C>Impl_ok` arguments for each component."""
    if not comps:
        raise ValueError("comps must not be empty")
    args = " ".join(f"{c}Impl_ok" for c in comps)
    return (
        f"theorem system_sound_{group}_inst : {group}SystemSpec.Satisfies {system_impl_name(group)} :=\n"
        f"  system_sound_{group} {args}"
    )
