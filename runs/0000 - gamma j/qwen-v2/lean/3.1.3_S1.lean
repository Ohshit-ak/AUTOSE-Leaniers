-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- checked: False

structure Input where
  name     : String
  contact  : String
  history  : List String
  order    : String
  deriving DecidableEq, Repr

structure Output where
  accountCreated : Bool
  contactUpdated : Bool
  historyViewed  : Bool
  orderConfirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name.length > 0 ∧ i.contact.length > 0 ∧ i.history.Nodup ∧ i.order.length > 0
  post := fun i o => o.accountCreated = true ∧
                     o.contactUpdated = i.contact.length > 0 ∧
                     o.historyViewed = i.history.Nodup ∧
                     o.orderConfirmed = i.order.length > 0

example : Spec.pre { name := "John Doe", contact := "jdoe@example.com", history := ["Order1", "Order2"], order := "NewOrder" } ∧
          Spec.post { name := "John Doe", contact := "jdoe@example.com", history := ["Order1", "Order2"], order := "NewOrder" }
                    { accountCreated := true, contactUpdated := true, historyViewed := true, orderConfirmed := true } := by
  unfold Spec; decide
