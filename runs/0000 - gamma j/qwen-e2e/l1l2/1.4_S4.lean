import ContractForge
open ContractForge

-- 1.4/S4: The minimum total inventory will be 20,000 items.

-- L0 spec

structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items ≥ 20000
  post := fun i o => o.items = i.items

example : Spec.pre { items := 20000 } ∧ Spec.post { items := 20000 } { items := 20000 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items ≥ 20000
  post := fun i o => o.items = i.items

def Component1Contract : Contract Input Input := 
  { pre := fun i => i.items ≥ 20000
    post := fun i i' => i'.items = i.items }

def Component2Contract : Contract Input Output := 
  { pre := fun i => i.items ≥ 20000
    post := fun i o => o.items = i.items }

-- Prove PO1: Component1Contract's assumption follows from Spec's guarantee
example : Contract.Compatible Component1Contract Spec := by
  discharge_po

-- Prove PO2: Component2Contract's assumption follows from Component1Contract's guarantee
example : Contract.Compatible Component2Contract Component1Contract := by
  discharge_po

-- Prove PO2: Component2Contract.refines Spec
example : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  discharge_po