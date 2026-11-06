import ContractForge
open ContractForge

-- 1.4/S2: The initial inventory will be 100 items.

-- L0 spec

structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items = 100
  post := fun i o => o.items = i.items

example : Spec.pre { items := 100 } ∧ Spec.post { items := 100 } { items := 100 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items = 100
  post := fun i o => o.items = i.items

-- Decompose the spec into two components

def Component1Contract : Contract Input Input := 
  { pre  := fun i => i.items = 100
    post := fun i i' => i'.items = i.items }

def Component2Contract : Contract Input Output := 
  { pre  := fun i => i.items = 100
    post := fun i o => o.items = i.items }

-- Prove PO1: each component's assumption follows from its predecessor's guarantee
theorem PO1 : Contract.Compatible Component1Contract Component2Contract := by
  intros i i' o h1 h2
  simp [h2] at h1
  exact h1

-- Prove PO2: the composition refines the spec
theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  intros i o h1 h2
  simp [h2] at h1
  exact h1

-- Check the contracts
example : Component1Contract.pre { items := 100 } ∧ Component1Contract.post { items := 100 } { items := 100 } := by
  unfold Component1Contract; decide

example : Component2Contract.pre { items := 100 } ∧ Component2Contract.post { items := 100 } { items := 100 } := by
  unfold Component2Contract; decide

example : Spec.pre { items := 100 } ∧ Spec.post { items := 100 } { items := 100 } := by
  unfold Spec; decide