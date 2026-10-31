import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- compiles: True · rejects_bad_example: None · checked: True

structure Account where
  username : String
  password : String
  contactInfo : String
  purchaseHistory : List String
  orderStatus : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  contactInfo : String
  purchaseHistory : List String
  orderStatus : String
  deriving DecidableEq, Repr

structure Output where
  username : String
  password : String
  contactInfo : String
  purchaseHistory : List String
  orderStatus : String
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.contactInfo ≠ ""
  post := fun i o => o.username = i.username ∧
                     o.password = i.password ∧
                     o.contactInfo = i.contactInfo ∧
                     o.purchaseHistory = i.purchaseHistory ∧
                     o.orderStatus = i.orderStatus ∧
                     o.confirmed = true

example : Spec.pre { username := "john", password := "pass123", contactInfo := "123 Main St", purchaseHistory := [], orderStatus := "pending" } ∧
          Spec.post { username := "john", password := "pass123", contactInfo := "123 Main St", purchaseHistory := [], orderStatus := "pending" }
                    { username := "john", password := "pass123", contactInfo := "123 Main St", purchaseHistory := [], orderStatus := "pending", confirmed := true } := by
  unfold Spec; decide
