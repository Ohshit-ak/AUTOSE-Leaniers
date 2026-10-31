import ContractForge
open ContractForge

-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- compiles: True · rejects_bad_example: None · checked: False

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
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.items.Nodup
  post := fun i o => o.confirmed ↔
    (i.cart.items.length > 0 ∧
     o.message = "Order confirmed for " ++ i.customer.name ++ ".")

example : Spec.pre { cart := { items := ["item1", "item2"] },
                     customer := { name := "Alice", email := "alice@example.com" } } ∧
          Spec.post { cart := { items := ["item1", "item2"] },
                      customer := { name := "Alice", email := "alice@example.com" } }
                    { confirmed := true, message := "Order confirmed for Alice." } := by
  unfold Spec; decide
