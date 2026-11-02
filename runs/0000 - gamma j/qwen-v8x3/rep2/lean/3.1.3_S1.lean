import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  contactInfo : String
  purchaseHistory : List String
  orderStatus : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  contactInfo : String
  deriving DecidableEq, Repr

structure Output where
  accounts : List Account
  orderStatus : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.accounts = i.accounts ∧
    o.orderStatus = "confirmed" ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password)

example : Spec.pre { accounts := [], username := "john", password := "pass1", contactInfo := "info1" } ∧ Spec.post { accounts := [], username := "john", password := "pass1", contactInfo := "info1" } { accounts := [{ username := "john", password := "pass1", contactInfo := "info1", purchaseHistory := ["history1"], orderStatus := "confirmed" }], orderStatus := "confirmed" } := by
  unfold Spec; decide
