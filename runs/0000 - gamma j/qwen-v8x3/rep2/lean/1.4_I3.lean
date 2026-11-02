import ContractForge
open ContractForge

-- 1.4/I3: Confirm Orders
-- compiles: True · rejects_bad_example: True · checked: True

structure Cart where
  items : List String
  deriving DecidableEq, Repr

structure Input where
  stock : List String
  cart  : Cart
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  message  : String
  items    : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.items.Nodup
  post := fun i o => (o.accepted ↔ i.cart.items.all (fun item => i.stock.contains item)) ∧
                     (o.accepted ↔ o.message = "Order accepted") ∧
                     (o.accepted → o.items = i.cart.items)

example : Spec.pre { stock := ["apple", "banana", "orange"], cart := { items := ["apple", "banana"] } } ∧
          Spec.post { stock := ["apple", "banana", "orange"], cart := { items := ["apple", "banana"] } }
                    { accepted := true, message := "Order accepted", items := ["apple", "banana"] } := by
  unfold Spec; decide
