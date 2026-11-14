import ContractForge
open ContractForge

-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- compiles: True · rejects_bad_example: True · checked: True

structure Cart where
  items : List String
  deriving DecidableEq, Repr

structure Customer where
  name : String
  address : String
  deriving DecidableEq, Repr

structure Input where
  cart : Cart
  customer : Customer
  confirming : Bool
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.confirming = true
  post := fun i o => (o.confirmed = true ↔ i.cart.items.Nodup) ∧
                     (o.confirmed = false → o.message = "Order cannot be confirmed: items are not unique")

example : Spec.pre { cart := { items := ["apple", "banana", "apple"] }, customer := { name := "John Doe", address := "123 Main St" }, confirming := true } ∧
          Spec.post { cart := { items := ["apple", "banana", "apple"] }, customer := { name := "John Doe", address := "123 Main St" }, confirming := true }
                    { confirmed := false, message := "Order cannot be confirmed: items are not unique" } := by
  unfold Spec; decide
