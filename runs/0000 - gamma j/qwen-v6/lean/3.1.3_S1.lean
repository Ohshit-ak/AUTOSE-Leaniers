import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- compiles: True · rejects_bad_example: None · checked: True

structure Account where
  username : String
  password : String
  contactInfo : String
  purchaseHistory : List String
  confirmedOrders : List String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  contactInfo : String
  deriving DecidableEq, Repr

structure Output where
  account : Account
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.contactInfo ≠ ""
  post := fun i o => o.account.username = i.username ∧
                     o.account.password = i.password ∧
                     o.account.contactInfo = i.contactInfo ∧
                     o.account.purchaseHistory = [] ∧
                     o.account.confirmedOrders = []

example : Spec.pre { accounts := [], username := "john", password := "pass123", contactInfo := "john@example.com" } ∧
          Spec.post { accounts := [], username := "john", password := "pass123", contactInfo := "john@example.com" }
                    { account := { username := "john", password := "pass123", contactInfo := "john@example.com", purchaseHistory := [], confirmedOrders := [] } } := by
  unfold Spec; decide
