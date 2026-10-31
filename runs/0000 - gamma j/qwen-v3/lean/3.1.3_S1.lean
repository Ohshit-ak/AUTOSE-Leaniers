-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- checked: True

structure Input where
  name        : String
  email       : String
  contactInfo : String
  purchaseHistory : List String
  orderStatus : String
  deriving DecidableEq, Repr

structure Output where
  accountCreated : Bool
  contactInfoConfigured : Bool
  purchaseHistoryViewed : Bool
  orderConfirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ "" ∧ i.contactInfo ≠ "" ∧ i.purchaseHistory.Nodup
  post := fun i o => o.accountCreated = true ∧
                     o.contactInfoConfigured = true ∧
                     o.purchaseHistoryViewed = true ∧
                     o.orderConfirmed = (i.orderStatus = "confirmed")

example : Spec.pre { name := "John Doe", email := "johndoe@example.com", contactInfo := "123-456-7890", purchaseHistory := ["Product A", "Product B"], orderStatus := "confirmed" } ∧
          Spec.post { name := "John Doe", email := "johndoe@example.com", contactInfo := "123-456-7890", purchaseHistory := ["Product A", "Product B"], orderStatus := "confirmed" }
                    { accountCreated := true, contactInfoConfigured := true, purchaseHistoryViewed := true, orderConfirmed := true } := by
  unfold Spec; decide
