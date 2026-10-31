import ContractForge
open ContractForge

-- 5.1/R4: The system shall be able to add product to shopping cart in less than 2ms.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  productID : Nat
  cartItems : List Nat
  deriving DecidableEq, Repr

structure Output where
  added : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.productID ≠ 0
  post := fun i o => o.added = true ↔
                     (o.elapsedMicros < 2000)

example : Spec.pre { productID := 1, cartItems := [] } ∧
          Spec.post { productID := 1, cartItems := [] }
                    { added := true, elapsedMicros := 1999 } := by
  unfold Spec; decide
