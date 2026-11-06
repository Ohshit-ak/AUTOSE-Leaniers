import ContractForge
open ContractForge

-- 5.1/R6: The system shall be able to email customer and vendor in less than 1 second.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 1000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 900000 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 1000000

-- Decompose the spec into two components

def Component1Contract : Contract Input Nat := 
  pre  := fun _ => True
  post := fun _ n => n < 1000000

def Component2Contract : Contract Nat Output := 
  pre  := fun n => n < 1000000
  post := fun n o => o.elapsedMicros = n

-- Prove PO1: Component1Contract is compatible with Component2Contract
example : Contract.Compatible Component1Contract Component2Contract := by
  discharge_po

-- Prove PO2: The composition of Component1Contract and Component2Contract refines the spec
example : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  unfold Component1Contract Component2Contract Spec; discharge_po