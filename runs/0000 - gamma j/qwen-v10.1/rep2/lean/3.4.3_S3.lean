import ContractForge
open ContractForge

-- 3.4.3/S3: The customer will then receive a confirmation email with the specific order details.
-- compiles: True · rejects_bad_example: True · checked: True

structure Order where
  id       : Nat
  customer : String
  items    : List String
  total    : Nat
  deriving DecidableEq, Repr

structure Input where
  customerEmail : String
  order         : Order
  deriving DecidableEq, Repr

structure Output where
  sentTo : String
  order  : Order
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ ""
  post := fun i o => (o.sentTo = i.customerEmail) ∧
                     (o.order.id = i.order.id) ∧
                     (o.order.customer = i.order.customer) ∧
                     (o.order.items = i.order.items) ∧
                     (o.order.total = i.order.total)

example : Spec.pre { customerEmail := "customer@example.com", order := { id := 1, customer := "John Doe", items := ["Item1", "Item2"], total := 100 } } ∧
          Spec.post { customerEmail := "customer@example.com", order := { id := 1, customer := "John Doe", items := ["Item1", "Item2"], total := 100 } }
                    { sentTo := "customer@example.com", order := { id := 1, customer := "John Doe", items := ["Item1", "Item2"], total := 100 } } := by
  unfold Spec; decide
