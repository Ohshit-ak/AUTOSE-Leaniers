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

end ContractForge
