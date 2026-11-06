import ContractForge
open ContractForge

-- DD-quantity: the number of units of each selected item that the customer is ordering; default = 1; maximum = quantity presently in inventory

-- L0 spec

structure Input where
  value : Nat
  max_ref : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ 1 ≤ i.value ∧ i.value ≤ i.max_ref

example : Spec.pre { value := 5, max_ref := 10 } ∧
          Spec.post { value := 5, max_ref := 10 } { valid := true } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  value : Nat
  max_ref : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ 1 ≤ i.value ∧ i.value ≤ i.max_ref

-- Decompose the spec into two components

def Component1Contract : Contract Input Output := 
  { pre  := fun i => 1 ≤ i.value ∧ i.value ≤ i.max_ref
    post := fun i o => o.valid = true }

def Component2Contract : Contract Input Output := 
  { pre  := fun _ => True
    post := fun i o => o.valid = true }

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1_Component1 : Contract.Compatible Component2Contract Component1Contract := by
  intro i o h
  unfold Component2Contract Component1Contract
  simp [h]
  exact (le_of_and_left h).trans (le_of_and_right h)

-- Prove PO2: the composition refines the spec

theorem PO2_CompositionRefinesSpec : Contract.Refines (Component2Contract.seq Component1Contract) Spec := by
  intro i o h
  unfold Component2Contract Component1Contract Spec
  simp [h]
  exact (le_of_and_left h).trans (le_of_and_right h)

-- Discharge PO1 and PO2
discharge_po