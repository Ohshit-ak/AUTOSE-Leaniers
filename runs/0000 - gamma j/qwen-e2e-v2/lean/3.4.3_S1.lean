import ContractForge
open ContractForge

-- 3.4.3/S1: Customers will be able to confirm the order after checkout.
-- compiles: True · rejects_bad_example: True · checked: True

structure Cart where
  items : List String
  deriving DecidableEq, Repr

structure Order where
  items : List String
  confirmed : Bool
  deriving DecidableEq, Repr

structure Input where
  cart : Cart
  deriving DecidableEq, Repr

structure Output where
  order : Order
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.items.Nodup
  post := fun i o => o.order.items = i.cart.items ∧
                     o.order.confirmed = true ∧
                     o.order.items.Nodup

example : Spec.pre { cart := { items := ["apple", "banana"] } } ∧
          Spec.post { cart := { items := ["apple", "banana"] } }
                    { order := { items := ["apple", "banana"], confirmed := true } } := by
  unfold Spec; decide
