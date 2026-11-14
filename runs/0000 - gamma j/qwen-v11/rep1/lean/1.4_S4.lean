import ContractForge
open ContractForge

-- 1.4/S4: The minimum total inventory will be 20,000 items.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 20000 ≤ i.items
  post := fun i o => o.items = i.items ∧
                     (o.items = i.items ↔ 20000 ≤ i.items)

example : Spec.pre { items := 20000 } ∧ Spec.post { items := 20000 } { items := 20000 } := by
  unfold Spec; decide
