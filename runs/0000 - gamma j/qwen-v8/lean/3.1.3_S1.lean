import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  contactInfo : String
  purchaseHistory : List String
  orderConfirmed : Bool
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  contactInfo : String
  purchaseHistory : List String
  orderConfirmed : Bool
  deriving DecidableEq, Repr

structure Output where
  username : String
  password : String
  contactInfo : String
  purchaseHistory : List String
  orderConfirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.contactInfo ≠ ""
  post := fun i o => o.username = i.username ∧
                     o.password = i.password ∧
                     o.contactInfo = i.contactInfo ∧
                     o.purchaseHistory = i.purchaseHistory ∧
                     o.orderConfirmed = i.orderConfirmed

example : Spec.pre { username := "john", password := "pass123", contactInfo := "info", purchaseHistory := [], orderConfirmed := false } ∧
          Spec.post { username := "john", password := "pass123", contactInfo := "info", purchaseHistory := [], orderConfirmed := false }
                    { username := "john", password := "pass123", contactInfo := "info", purchaseHistory := [], orderConfirmed := false } := by
  unfold Spec; decide
