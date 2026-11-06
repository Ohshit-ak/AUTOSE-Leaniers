import ContractForge
open ContractForge

-- 5.1/R4: The system shall be able to add product to shopping cart in less than 2ms.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 2000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 1999 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 2000

-- Decompose the spec into two components
def Component1Contract : Contract Input (Output × Nat) := 
  { pre  := fun i => True,
    post := fun i (o, micros) => micros < 2000 }

def Component2Contract : Contract (Output × Nat) Output := 
  { pre  := fun (o, micros) => micros < 2000,
    post := fun (o, micros) o' => o' = o }

-- Prove PO1: each component's assumption follows from its predecessor's guarantee
theorem PO1 : Contract.Compatible Component1Contract Spec := by
  unfold Component1Contract Spec; discharge_po

-- Prove PO2: the composition refines the spec
theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  unfold Component1Contract Component2Contract Spec; discharge_po