import ContractForge
open ContractForge

-- DD-price: Cost of a single unit of the selected item; in dollars and cents.

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

example : Spec.pre { value := 1234 } ∧
          Spec.post { value := 1234 } { valid := true } := by
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

theorem PO1_Component1 : Contract.Compatible Component1Contract.pre Spec.pre := by
  intros i hi
  unfold Component1Contract.pre
  unfold Spec.pre
  exact hi

theorem PO1_Component2 : Contract.Compatible Component2Contract.pre Component1Contract.post := by
  intros o ho
  unfold Component2Contract.pre
  unfold Component1Contract.post
  exact ho

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  unfold Component1Contract.seq
  unfold Component2Contract.seq
  unfold Spec
  intros i hi
  unfold Component1Contract.pre
  unfold Component2Contract.pre
  unfold Component1Contract.post
  unfold Component2Contract.post
  simp [hi]
  exact (hi ▸ Component1Contract.post i (Component2Contract.post i))
  discharge_po

-- Example to check the contracts
example : Component1Contract.pre { value := 1234 } ∧
          Component1Contract.post { value := 1234 } { valid := true } := by
  unfold Component1Contract.pre
  unfold Component1Contract.post
  decide

example : Component2Contract.pre { valid := true } ∧
          Component2Contract.post { value := 1234 } { valid := true } := by
  unfold Component2Contract.pre
  unfold Component2Contract.post
  decide