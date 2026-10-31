import ContractForge
open ContractForge

-- DD-shipping-price: Cost for shipping the item to its destination; in dollars and cents
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  value : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ (100 ≤ i.value ∧ i.value ≤ 10000)

example : Spec.pre { value := 1234 } ∧
          Spec.post { value := 1234 }
                    { valid := true } := by
  unfold Spec; decide
