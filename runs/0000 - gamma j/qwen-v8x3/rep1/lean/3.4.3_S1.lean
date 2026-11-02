import ContractForge
open ContractForge

-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- compiles: True · rejects_bad_example: True · checked: True

structure Cart where
  items : List String
  deriving DecidableEq, Repr

structure Customer where
  name : String
  email : String
  deriving DecidableEq, Repr

structure Input where
  cart : Cart
  customer : Customer
  confirmed : Bool
  deriving DecidableEq, Repr

structure Output where
  cart : Cart
  customer : Customer
  confirmed : Bool
  orderPlaced : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.confirmed = true
  post := fun i o => o.confirmed = i.confirmed ∧
                     o.orderPlaced ↔ i.cart.items.Nodup ∧
                     o.customer = i.customer

example : Spec.pre { cart := { items := ["item1", "item2"] }, customer := { name := "John", email := "john@example.com" }, confirmed := true } ∧
          Spec.post { cart := { items := ["item1", "item2"] }, customer := { name := "John", email := "john@example.com" }, confirmed := true }
                    { cart := { items := ["item1", "item2"] }, customer := { name := "John", email := "john@example.com" }, confirmed := true, orderPlaced := true } := by
  unfold Spec; decide
