import ContractForge
open ContractForge

-- 5.1/R9: The system shall be able to restore 1000 records per second.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  perSecond : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.perSecond ≥ 1000

example : Spec.pre {} ∧ Spec.post {} { perSecond := 1001 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  deriving DecidableEq, Repr

structure Output where
  perSecond : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.perSecond ≥ 1000

-- Decompose the spec into two components
def Component1Contract : Contract Input Output := 
  { pre  := fun _ => True
    post := fun _ o => o.perSecond ≥ 1000 }

def Component2Contract : Contract Output Output := 
  { pre  := fun o => o.perSecond ≥ 1000
    post := fun o _ => o.perSecond ≥ 1000 }

-- Prove PO1: Component1Contract's assumption follows from Spec's guarantee
example : Contract.Compatible Component1Contract Spec := by
  discharge_po

-- Prove PO2: the composition refines the spec
example : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  discharge_po