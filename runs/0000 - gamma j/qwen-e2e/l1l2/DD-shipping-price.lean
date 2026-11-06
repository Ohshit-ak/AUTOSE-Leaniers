import ContractForge
open ContractForge

-- DD-shipping-price: Cost for shipping the item to its destination; in dollars and cents

-- L0 spec

structure Input where
  value : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ i.value ≤ 9999

example : Spec.pre { value := 500 } ∧ Spec.post { value := 500 } { valid := true } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  value : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ i.value ≤ 9999

-- Decompose the spec into two components

def Component1Contract : Contract Input Output := 
  { pre  := fun i => i.value ≤ 9999
    post := fun i o => o.valid = true }

def Component2Contract : Contract Input Output := 
  { pre  := fun o => o.valid = true
    post := fun i o => o.valid = true }

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1_Component1 : Contract.Compatible Component1Contract.Spec Component2Contract.Spec := by
  unfold Component1Contract Component2Contract Spec; discharge_po

theorem PO1_Component2 : Contract.Compatible Component2Contract.Spec Component1Contract.Spec := by
  unfold Component1Contract Component2Contract Spec; discharge_po

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  unfold Component1Contract Component2Contract Spec; discharge_po