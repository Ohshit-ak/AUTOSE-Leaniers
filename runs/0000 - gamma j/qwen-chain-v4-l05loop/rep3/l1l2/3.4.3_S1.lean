import ContractForge
open ContractForge

-- 3.4.3/S1: Customers will be able to confirm the order after checkout.

-- L0 spec

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
  post := fun i o => (o.confirmed = true ↔ i.cart.items.length > 0) ∧
                     (o.confirmed = false → o.message = "Cart is empty.")

example : Spec.pre { cart := { items := ["item1", "item2"] }, customer := { name := "John Doe", email := "john@example.com" } } ∧
          Spec.post { cart := { items := ["item1", "item2"] }, customer := { name := "John Doe", email := "john@example.com" } }
                    { confirmed := true, message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  confirmed : Bool
  deriving DecidableEq, Repr

def CheckCartContract : Contract Input Mid where
  pre  := fun i => i.cart.items.Nodup
  post := fun i m => m.confirmed = true ↔ i.cart.items.length > 0

def FormatMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (m.confirmed = true → o.message = "") ∧
                     (m.confirmed = false → o.message = "Cart is empty.")
