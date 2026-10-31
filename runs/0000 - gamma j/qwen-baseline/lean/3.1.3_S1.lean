-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- checked: False

structure Input where
  action : String
  profile : String
  contactInfo : String
  purchaseHistory : List String
  order : String

structure Output where
  success : Bool
  profileUpdated : Bool
  contactInfoConfigured : Bool
  purchaseHistoryViewed : Bool
  orderConfirmed : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.action ∈ ["create", "configure", "view", "confirm"]
  post := fun i o => 
    o.success = true ∧
    (i.action = "create" → i.profile ≠ "" ∧ i.contactInfo ≠ "" ∧ i.purchaseHistory = []) ∧
    (i.action = "configure" → i.contactInfoConfigured = true) ∧
    (i.action = "view" → i.purchaseHistoryViewed = true) ∧
    (i.action = "confirm" → i.orderConfirmed = true)

example : Spec.pre ⟨"create", "John Doe", "123-456-7890", [], "Order123"⟩ ∧ Spec.post ⟨"create", "John Doe", "123-456-7890", [], "Order123"⟩ ⟨true, true, true, true, false⟩ := by
  simp [Spec]
