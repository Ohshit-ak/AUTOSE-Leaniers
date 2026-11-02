import ContractForge
open ContractForge

-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- compiles: True · rejects_bad_example: None · checked: True

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
  confirming : Bool
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.confirming = true
  post := fun i o => o.confirmed = true ∧
                     o.message = "Order confirmed for " ++ i.customer.name

example : Spec.pre { cart := { items := ["item1", "item2"] },
                     customer := { name := "John Doe", email := "johndoe@example.com" },
                     confirming := true } ∧
          Spec.post { cart := { items := ["item1", "item2"] },
                      customer := { name := "John Doe", email := "johndoe@example.com" },
                      confirming := true }
                    { confirmed := true, message := "Order confirmed for John Doe" } := by
  unfold Spec; decide
