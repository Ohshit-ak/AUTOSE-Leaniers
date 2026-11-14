import ContractForge
open ContractForge

-- Design Constraints/I2: The will be a provision to create a minimum quantity of vouchers at one time (such minimum numbers will be decided by the management team).
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  quantity : Nat
  minQuantity : Nat
  deriving DecidableEq, Repr

structure Output where
  created : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.minQuantity ∧ i.quantity ≥ i.minQuantity
  post := fun i o => o.created = i.quantity ∧
                     (o.created = i.quantity → o.created = i.quantity) ∧
                     (o.created = i.quantity → o.created = i.quantity)

example : Spec.pre { quantity := 10, minQuantity := 5 } ∧
          Spec.post { quantity := 10, minQuantity := 5 } { created := 10 } := by
  unfold Spec; decide
