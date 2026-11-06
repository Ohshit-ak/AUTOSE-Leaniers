import ContractForge
open ContractForge

-- 5.1/R3: The system shall be able to retrieve 200 products per second.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  perSecond : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.perSecond ≥ 200

example : Spec.pre {} ∧ Spec.post {} { perSecond := 250 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  deriving DecidableEq, Repr

structure Output where
  perSecond : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.perSecond ≥ 200

-- Decompose the spec into two components

def Component1Contract : Contract Input (Output × Nat) := 
  { pre  := fun _ => True
    post := fun _ (o, p) => p ≥ 200 }

def Component2Contract : Contract (Output × Nat) Output := 
  { pre  := fun (o, p) => p ≥ 200
    post := fun (o, p) o' => o' = o }

-- Prove PO1: Component1Contract's assumption follows from Spec's guarantee
theorem PO1 : Contract.Compatible Component1Contract Spec := by
  intro i
  unfold Component1Contract Spec
  constructor
  -- pre condition is trivially true
  exact trivial
  -- post condition
  simp only [Component1Contract.post, Spec.post]
  exact trivial

-- Prove PO2: the composition refines the spec
theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  intro i
  unfold Component1Contract Component2Contract Spec
  constructor
  -- pre condition is trivially true
  exact trivial
  -- post condition
  simp only [Component1Contract.post, Component2Contract.post, Spec.post]
  exact trivial

-- Define the composition of the two contracts
def Component12Contract : Contract Input Output := 
  Component1Contract.seq Component2Contract

-- Prove PO1 and PO2 for the composition
theorem PO1_12 : Contract.Compatible Component12Contract Spec := by
  discharge_po

theorem PO2_12 : Contract.Refines Component12Contract Spec := by
  discharge_po