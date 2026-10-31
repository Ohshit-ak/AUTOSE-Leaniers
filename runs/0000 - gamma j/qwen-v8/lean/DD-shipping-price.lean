import ContractForge
open ContractForge

-- DD-shipping-price: Cost for shipping the item to its destination; in dollars and cents
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  value : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ 0 ≤ i.value ∧ i.value ≤ 9999

example : Spec.pre { value := 500 } ∧
          Spec.post { value := 500 } { valid := true } := by
  unfold Spec; decide
