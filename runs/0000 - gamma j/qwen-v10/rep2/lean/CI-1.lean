import ContractForge
open ContractForge

-- CI-1: The WebOrder system shall send an e-mail confirmation to the customer that the items they ordered will be delivered to the shipping address along with tracking number.
-- compiles: True · rejects_bad_example: True · checked: True

structure Order where
  items    : List String
  address  : String
  tracking : String
  deriving DecidableEq, Repr

structure Email where
  to       : String
  subject  : String
  content  : String
  deriving DecidableEq, Repr

structure Input where
  order  : Order
  email  : Email
  deriving DecidableEq, Repr

structure Output where
  sentTo : String
  subject: String
  content: String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.order.items ≠ [] ∧ i.email.to ≠ ""
  post := fun i o =>
    (o.sentTo = i.email.to ∧
     o.subject = i.email.subject ∧
     o.content = "Your order will be delivered to " ++ i.order.address ++ " with tracking number " ++ i.order.tracking ++ ".") ↔
    i.order.items ≠ []

example : Spec.pre { order := { items := ["item1", "item2"], address := "123 Main St", tracking := "1234567890" },
                     email := { to := "customer@example.com", subject := "Order Confirmation", content := "Dear customer," } } ∧
          Spec.post { order := { items := ["item1", "item2"], address := "123 Main St", tracking := "1234567890" },
                      email := { to := "customer@example.com", subject := "Order Confirmation", content := "Dear customer," } }
                    { sentTo := "customer@example.com", subject := "Order Confirmation", content := "Your order will be delivered to 123 Main St with tracking number 1234567890." } := by
  unfold Spec; decide
