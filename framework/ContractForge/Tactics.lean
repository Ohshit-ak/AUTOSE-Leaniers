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

/-- PO1 `Compatible A B` after unfolding the named contracts: the goal is
`∀ x y, A.pre x → A.post x y → B.pre y`. Tries the hypotheses as they are, then with the
records split into their fields. (`done` first: unfolding alone closes a `True` goal.) -/
macro "discharge_po1" " [" ids:ident,* "]" : tactic => `(tactic| (
  simp only [ContractForge.Contract.Compatible, $[$ids:ident],*]
  first
  | done
  | (intro x y hpre hpost
     first
     | done
     | (simp_all; done)
     | omega
     | grind
     | (cases x; cases y; simp_all; done)
     | (cases x; cases y; grind))))

/-- PO2 `Refines (A.seq B) Spec` after unfolding the named contracts. The `pre` half is
`Spec.pre x → A.pre x`. In the `post` half the middle value of `seq` is a hypothesis
`∃ y, A.post x y ∧ B.post y z`: it is taken apart (`obtain`) before the closers run, which
`simp_all`/`omega`/`grind` on their own never do. -/
macro "discharge_po2" " [" ids:ident,* "]" : tactic => `(tactic| (
  simp only [ContractForge.Contract.Refines, ContractForge.Contract.seq, $[$ids:ident],*]
  first
  | done
  | (refine ⟨?_, ?_⟩
     · first
       | done
       | (intro x h
          first
          | done
          | exact h
          | (simp_all; done)
          | omega
          | grind)
     · first
       | done
       | (intro x z hpre h
          obtain ⟨y, hA, hB⟩ := h
          first
          | done
          | (simp_all; done)
          | omega
          | grind
          | (cases x; cases y; cases z; simp_all; done)
          | (cases x; cases y; cases z; grind)))))

/-- PO3 `C.Satisfies f` after unfolding the named contract and implementation: the goal is
`∀ x, C.pre x → C.post x (f x)`. An implementation that branches (`if … then … else`) is
split into its cases. -/
macro "discharge_po3" " [" ids:ident,* "]" : tactic => `(tactic| (
  simp only [ContractForge.Contract.Satisfies, $[$ids:ident],*]
  first
  | done
  | (intro x hpre
     first
     | done
     | (simp_all; done)
     | omega
     | grind
     | (split <;> simp_all; done)
     | (split <;> grind)
     | (cases x; simp_all; done)
     | (cases x; grind)
     | decide)))

end ContractForge
