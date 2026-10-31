import ContractForge
open ContractForge

-- 5.1/R4: The system shall be able to add product to shopping cart in less than 2ms.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  productID : Nat
  cart      : List Nat
  deriving DecidableEq, Repr

structure Output where
  added     : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productID ≠ 0
  post := fun i o => o.added = true ↔ i.productID ∉ i.cart ∧
                      (o.elapsedMicros < 2000)

example : Spec.pre { productID := 1, cart := [2, 3] } ∧
          Spec.post { productID := 1, cart := [2, 3] }
                    { added := true, elapsedMicros := 1500 } := by
  unfold Spec; decide
