import ContractForge.Contract

namespace ContractForge

/-- First-try automation for proof obligations: unfold the PO definitions,
then try a few closers. Agents fall back to manual tactics if this fails. -/
macro "discharge_po" : tactic => `(tactic| (
  try simp only [ContractForge.Contract.Satisfies, ContractForge.Contract.Compatible,
    ContractForge.Contract.Refines, ContractForge.Contract.seq] at *
  first
  | done
  | (intros; simp_all; done)
  | (intros; omega)
  | (intros; grind)
  | decide))

/-- `discharge_po [A, B, Spec]`: unfold the named contracts too, then the same closers.
Without the names, `pre`/`post` of user contracts stay opaque and the closers fail. -/
macro "discharge_po" " [" ids:ident,* "]" : tactic => `(tactic| (
  simp only [ContractForge.Contract.Satisfies, ContractForge.Contract.Compatible,
    ContractForge.Contract.Refines, ContractForge.Contract.seq, $[$ids:ident],*] at *
  first
  | done
  | (intros; simp_all; done)
  | (refine ⟨fun _ h => by simp_all, ?_⟩; intros; simp_all; done)
  | (intros; omega)
  | (intros; grind)))

end ContractForge
