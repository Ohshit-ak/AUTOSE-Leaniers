import ContractForge
open ContractForge

-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- compiles: True · rejects_bad_example: None · checked: True

structure Cart where
  items : List String
  deriving DecidableEq, Repr

structure Customer where
  email : String
  deriving DecidableEq, Repr

structure Input where
  email : String
  cart  : Cart
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  message   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ ""
  post := fun i o => o.confirmed = true ↔ i.cart.items.Nodup ∧
                     (o.confirmed = true → o.message = "Order confirmed") ∧
                     (o.confirmed = false → o.message = "Order not confirmed due to duplicate items")

example : Spec.pre { email := "customer@example.com", cart := { items := ["item1", "item2"] } } ∧
          Spec.post { email := "customer@example.com", cart := { items := ["item1", "item2"] } }
                    { confirmed := true, message := "Order confirmed" } := by
  unfold Spec; decide
