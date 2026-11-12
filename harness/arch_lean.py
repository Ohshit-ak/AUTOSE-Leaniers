"""L1 Lean text, written by the harness (no model). Deterministic: same inputs → same text.

One *group* (a connected subsystem of the requirements graph) becomes one Lean system:

    namespace L0_<op> … end L0_<op>      each L0 spec, unchanged except its `example` dropped
    inductive <G>Msg                       req_<op> (L0 Input) | res_<op> (L0 Output), per op
    def <G>SystemSpec : Contract Msg Msg   the conjunction of the L0 specs, one `match` case per op
    def <C>_pre_<op> / <C>_post_<op>       written by the model, for the ops component C owns
    def <C>Contract : Contract Msg Msg     assembled by the harness: owned requests use the model's
                                           pre/post; everything else passes through unchanged
    theorem trace_pre/post_<C>_<op>        the contract covers that L0 spec          (trace)
    theorem po1_<A>_<B>                    Contract.Compatible, consecutive components (PO1)
    theorem po2_<G>                        the chain refines <G>SystemSpec            (PO2)
    theorem system_sound_<G>               end-to-end statement, proved from the above

The model only writes the `_pre_`/`_post_` definitions (plus helper defs) and proof bodies.
Every statement above is written here, so the model cannot change what is proved.
"""
import hashlib
import re
from typing import Dict, List, Optional, Sequence

from agents.base import split_example
from po import FORBIDDEN, forbidden_words  # noqa: F401  (shared with the chain path; re-exported)

_IMPORT_OPEN = re.compile(r"^\s*(?:import|open)\s+.*$\n?", re.MULTILINE)
_DEF_NAME = re.compile(r"^(?:@\[[^\]]*\]\s*)?(?:noncomputable\s+)?(?:def|abbrev|theorem|lemma)\s+([\w.']+)",
                       re.MULTILINE)


def slug(op_id: str) -> str:
    """Lean-safe lower-case name of an operation id: `UC-customer-login` → `uc_customer_login`."""
    s = re.sub(r"[^A-Za-z0-9]+", "_", op_id).strip("_").lower()
    return s or "op"


def camel(name: str) -> str:
    """`cart line` / `cart_line` → `CartLine` (a Lean-safe component or group name)."""
    parts = [p for p in re.split(r"[^A-Za-z0-9]+", name) if p]
    out = "".join(p[:1].upper() + p[1:] for p in parts) or "C"
    return out if out[0].isalpha() else "C" + out


def sha(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:12]


def defined_names(code: str) -> List[str]:
    return _DEF_NAME.findall(code)


# ---------------------------------------------------------------------------
# Locked context: L0 specs, message type, system spec
# ---------------------------------------------------------------------------

def l0_block(op_id: str, code: str) -> str:
    """The L0 spec in its own namespace, without import/open lines and without its example."""
    defs, _ = split_example(_IMPORT_OPEN.sub("", code))
    s = slug(op_id)
    return f"namespace L0_{s}\n-- {op_id}\n{defs.strip()}\nend L0_{s}"


def msg_type(group: str, ops: Sequence[str]) -> str:
    lines = [f"/-- Messages of {group}: a request to and a response from each operation. -/",
             f"inductive {group}Msg where"]
    for op in ops:
        s = slug(op)
        lines.append(f"  | req_{s} (i : L0_{s}.Input)")
        lines.append(f"  | res_{s} (o : L0_{s}.Output)")
    return "\n".join(lines)


def system_spec(group: str, ops: Sequence[str]) -> str:
    """Request `req_a i` is accepted when L0_a's `pre` holds and must be answered by `res_a o`
    with L0_a's `post`. Anything else is not a valid system run."""
    pre = [f"    | .req_{slug(op)} i => L0_{slug(op)}.Spec.pre i" for op in ops]
    post = [f"    | .req_{slug(op)} i => ∃ o, m' = .res_{slug(op)} o ∧ L0_{slug(op)}.Spec.post i o"
            for op in ops]
    return "\n".join([
        f"/-- The system spec of {group}: every L0 spec of the group, one case per operation. -/",
        f"def {group}SystemSpec : Contract {group}Msg {group}Msg where",
        "  pre := fun m => match m with", *pre, "    | _ => False",
        "  post := fun m m' => match m with", *post, "    | _ => False"])


def locked_context(group: str, l0: Dict[str, str]) -> str:
    """Everything the model may read but not change, in a fixed order (ops sorted by id)."""
    ops = sorted(l0)
    blocks = [l0_block(op, l0[op]) for op in ops]
    return "\n\n".join(blocks + [msg_type(group, ops), system_spec(group, ops)])


# ---------------------------------------------------------------------------
# Components
# ---------------------------------------------------------------------------

def pre_name(comp: str, op: str) -> str:
    return f"{comp}_pre_{slug(op)}"


def post_name(comp: str, op: str) -> str:
    return f"{comp}_post_{slug(op)}"


def owned_signatures(comp: str, owned: Sequence[str]) -> str:
    """What the model must define for component `comp` (shown in the prompt)."""
    out = []
    for op in owned:
        s = slug(op)
        out.append(f"def {pre_name(comp, op)} (i : L0_{s}.Input) : Prop := …")
        out.append(f"def {post_name(comp, op)} (i : L0_{s}.Input) (o : L0_{s}.Output) : Prop := …")
    return "\n".join(out)


def contract_def(group: str, comp: str, owned: Sequence[str], all_ops: Sequence[str]) -> str:
    """`<comp>Contract`: owned requests use the model's pre/post; a request owned by another
    component is assumed to satisfy its L0 `pre` and passed on unchanged; responses pass."""
    owned_set = set(owned)
    pre, post = [], []
    for op in sorted(all_ops):
        s = slug(op)
        if op in owned_set:
            pre.append(f"    | .req_{s} i => {pre_name(comp, op)} i")
            post.append(f"    | .req_{s} i => ∃ o, m' = .res_{s} o ∧ {post_name(comp, op)} i o")
        else:
            pre.append(f"    | .req_{s} i => L0_{s}.Spec.pre i")
    return "\n".join([
        f"/-- Component {comp}: owns {', '.join(owned)}. -/",
        f"def {comp}Contract : Contract {group}Msg {group}Msg where",
        "  pre := fun m => match m with", *pre, "    | _ => True",
        "  post := fun m m' => match m with", *post, "    | _ => m' = m"])


# ---------------------------------------------------------------------------
# Proof obligations: statements (harness) and first-try proofs (harness)
# ---------------------------------------------------------------------------

def trace_pre_name(comp: str, op: str) -> str:
    return f"trace_pre_{comp}_{slug(op)}"


def trace_post_name(comp: str, op: str) -> str:
    return f"trace_post_{comp}_{slug(op)}"


def trace_statements(comp: str, op: str) -> Dict[str, str]:
    """The contract covers L0 spec `op`: it assumes no more and guarantees at least as much."""
    s = slug(op)
    return {
        "pre": (f"theorem {trace_pre_name(comp, op)} : ∀ i : L0_{s}.Input, "
                f"L0_{s}.Spec.pre i → {pre_name(comp, op)} i"),
        "post": (f"theorem {trace_post_name(comp, op)} : ∀ (i : L0_{s}.Input) (o : L0_{s}.Output), "
                 f"L0_{s}.Spec.pre i → {post_name(comp, op)} i o → L0_{s}.Spec.post i o"),
    }


def _simp_set(names: Sequence[str]) -> str:
    return ", ".join(dict.fromkeys(names))


def auto_trace_proof(comp: str, op: str, helpers: Sequence[str]) -> str:
    """First try for a trace obligation: unfold the model's defs and the L0 spec, then close."""
    s = slug(op)
    unfold = _simp_set([pre_name(comp, op), post_name(comp, op), f"L0_{s}.Spec", *helpers])
    return ("by\n  intros\n  first\n"
            f"  | (simp_all [{unfold}]; done)\n"
            f"  | (simp_all [{unfold}]; omega)\n"
            f"  | (unfold {pre_name(comp, op)} {post_name(comp, op)} at *; simp_all)\n"
            f"  | (simp_all [{unfold}]; decide)")


def po1_name(a: str, b: str) -> str:
    return f"po1_{a}_{b}"


def po1_statement(a: str, b: str) -> str:
    return f"theorem {po1_name(a, b)} : Contract.Compatible {a}Contract {b}Contract"


def _cases(alts: List[str]) -> str:
    return "\n".join(alts)


def auto_po1_proof(group: str, a: str, b: str, owner: Dict[str, str], ops: Sequence[str]) -> str:
    """A's guarantee establishes B's assumption, one branch per message: a request A owns
    leaves A as a response, of which B assumes nothing; any other message passes A unchanged,
    so a request B owns needs B's trace `pre` lemma and any other request keeps its L0 `pre`.
    Only definitional steps (`cases`, `obtain`, `exact`), no `simp`: a `simp` per branch over a
    large message type is quadratic and runs out of heartbeats."""
    alts = []
    for op in sorted(ops):
        s = slug(op)
        if owner.get(op) == a:
            step = "obtain ⟨_, rfl, _⟩ := hpost; exact trivial"
        elif owner.get(op) == b:
            step = f"cases hpost; exact {trace_pre_name(b, op)} i hpre"
        else:
            step = "cases hpost; exact hpre"
        alts.append(f"  | req_{s} i => {step}")
        alts.append(f"  | res_{s} o => cases hpost; exact trivial")
    return f"by\n  intro m m' hpre hpost\n  cases m with\n{_cases(alts)}"


def chain_expr(comps: Sequence[str]) -> str:
    """Left-nested chain `((c₁.seq c₂).seq c₃)` in the given order."""
    expr = f"{comps[0]}Contract"
    for c in comps[1:]:
        expr = f"({expr}).seq {c}Contract"
    return expr


def po2_name(group: str) -> str:
    return f"po2_{group}"


def po2_statement(group: str, comps: Sequence[str]) -> str:
    return f"theorem {po2_name(group)} : Contract.Refines ({chain_expr(comps)}) {group}SystemSpec"


def _chain_pattern(n: int) -> str:
    """rcases pattern for the post of an n-component chain: ⟨y_{n-1}, ⟨…⟨y1, h1, h2⟩…⟩, hn⟩."""
    pat = "h1"
    for k in range(2, n + 1):
        pat = f"⟨y{k - 1}, {pat}, h{k}⟩"
    return pat


def auto_po2_proof(group: str, comps: Sequence[str], owner: Dict[str, str], ops: Sequence[str]) -> str:
    """One branch per message, definitional steps only (see `auto_po1_proof`). Pre: the first
    component assumes no more than the system (its trace `pre` lemma for a request it owns;
    otherwise the L0 `pre` itself). Post: walk the chain: components before the owner pass the
    request on (`cases`), the owner answers it (`obtain ⟨o, rfl, h⟩`), later ones pass the
    response on; the owner's trace `post` lemma gives the L0 `post`. Responses are not system
    inputs (`pre` is `False`)."""
    n, first = len(comps), comps[0]
    pre_alts, post_alts = [], []
    for op in sorted(ops):
        s, own = slug(op), owner.get(op)
        close = f"exact {trace_pre_name(first, op)} i h" if own == first else "exact h"
        pre_alts.append(f"    | req_{s} i => {close}")
        pre_alts.append(f"    | res_{s} o => cases h")
        if own not in comps:
            raise ValueError(f"operation {op} has no component in the chain")
        steps, owner_k = [], 0
        for k, c in enumerate(comps, 1):
            if c == own:
                steps.append(f"obtain ⟨o, rfl, h{k}⟩ := h{k}")
                owner_k = k
            else:
                steps.append(f"cases h{k}")
        post_alts.append(f"    | req_{s} i =>\n      {'; '.join(steps)}\n"
                         f"      exact Exists.intro _ ⟨rfl, {trace_post_name(own, op)} i o hpre h{owner_k}⟩")
        post_alts.append(f"    | res_{s} o => cases hpre")
    intro = f"intro m z hpre h\n    obtain {_chain_pattern(n)} := h" if n > 1 else "intro m z hpre h1"
    return ("by\n  refine ⟨?_, ?_⟩\n"
            f"  · intro m h\n    cases m with\n{_cases(pre_alts)}\n"
            f"  · {intro}\n    cases m with\n{_cases(post_alts)}")


def system_sound_theorem(group: str, comps: Sequence[str]) -> Optional[str]:
    """`<G>SystemSpec.Satisfies` of the composed implementation from PO1/PO2 and PO3 for each
    component: the statement L2 instantiates. Built from Soundness/Chain theorems only."""
    n = len(comps)
    if n == 1:
        c = comps[0]
        return (f"theorem system_sound_{group} {{f : {group}Msg → {group}Msg}}\n"
                f"    (hf : {c}Contract.Satisfies f) : {group}SystemSpec.Satisfies f :=\n"
                f"  Contract.refines_sound {po2_name(group)} hf")
    fs = [f"f{k}" for k in range(1, n + 1)]
    binders = " ".join(f"{{{f} : {group}Msg → {group}Msg}}" for f in fs)
    hyps = "\n    ".join(f"(h{k} : {c}Contract.Satisfies {f})" for k, (c, f) in enumerate(zip(comps, fs), 1))
    impl = fs[0]
    for f in fs[1:]:
        impl = f"{f} ∘ ({impl})" if " " in impl else f"{f} ∘ {impl}"
    # compat: PO1 of the chain so far (c₁ … c_k) with c_{k+1}; sat: the chain so far meets its
    # composed contract. Built up with Chain.compat_seq and Soundness.seq_sound.
    compat, sat = po1_name(comps[0], comps[1]), "h1"
    for k in range(1, n - 1):  # extend the chain with comps[k]
        sat = f"(Contract.seq_sound {compat} {sat} h{k + 1})"
        compat = f"(Contract.compat_seq {compat} {po1_name(comps[k], comps[k + 1])})"
    return (f"theorem system_sound_{group} {binders}\n    {hyps} :\n"
            f"    {group}SystemSpec.Satisfies ({impl}) :=\n"
            f"  Contract.system_sound {compat} {po2_name(group)} {sat} h{n}")


def theorem(statement: str, proof: str) -> str:
    """`statement := proof`. A proof body without a leading `by` is a tactic block."""
    proof = proof.strip()
    if proof.startswith(":="):
        proof = proof[2:].strip()
    elif not re.match(r"by\b", proof):
        proof = "by\n" + "\n".join("  " + ln for ln in proof.splitlines())
    return f"{statement} := {proof}"
