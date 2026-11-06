import ContractForge
open ContractForge

-- REQ-1#3: Query times will take no longer than 5 seconds to any website.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 5000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 4500000 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 5000000

-- Decompose the spec into two components

def Component1Contract : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 1000000

def Component2Contract : Contract Output Output where
  pre  := fun o1 o2 => o1.elapsedMicros ≤ 1000000 → o2.elapsedMicros ≤ 5000000
  post := fun o1 o2 => o2.elapsedMicros ≤ 5000000

-- Prove PO1: Component1Contract and Component2Contract are compatible
theorem PO1 : Contract.Compatible Component1Contract Component2Contract := by
  unfold Contract.Compatible
  intros o1 o2 h1 h2
  simp [h1, h2]

-- Prove PO2: the composition of Component1Contract and Component2Contract refines the spec
theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  unfold Contract.Refines
  intros o1 o2 h1 h2
  simp [h1, h2]
  discharge_po

-- Example to check the correctness
example : (Component1Contract.seq Component2Contract).pre {} ∧ (Component1Contract.seq Component2Contract).post {} { elapsedMicros := 4500000 } := by
  unfold Component1Contract Component2Contract; decide