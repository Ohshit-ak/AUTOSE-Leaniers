import ContractForge
open ContractForge

-- 1.4/S2: The initial inventory will be 100 items.
-- compiles: True · rejects_bad_example: None · checked: True

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
