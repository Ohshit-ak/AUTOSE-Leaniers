import ContractForge
open ContractForge

-- 5.1/R8: The system shall be able to acquire shipping charges in less than 2 seconds.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 2000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 1999999 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 2000000

-- Decompose the spec into two components

def Component1Contract : Contract Input Output := 
  { pre  := fun _ => True
    post := fun _ o => o.elapsedMicros < 1000000 }

def Component2Contract : Contract Output Output := 
  { pre  := fun o => o.elapsedMicros < 1000000
    post := fun o => o.elapsedMicros < 2000000 }

-- Prove PO1: Component1Contract's assumption follows from Spec's guarantee
theorem PO1 : Contract.Compatible Component1Contract Spec := by
  intros o hspec
  unfold Component1Contract Spec
  simp [hspec]
  exact hspec

-- Prove PO2: The composition refines the spec
theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  intros o hspec
  unfold Component1Contract Component2Contract Spec
  simp [hspec]
  exact hspec