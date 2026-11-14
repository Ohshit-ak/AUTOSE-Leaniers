import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- compiles: True · rejects_bad_example: True · checked: True

structure CustomerProfile where
  name        : String
  email       : String
  phone       : String
  purchaseHistory : List String
  confirmedOrders : List String
  deriving DecidableEq, Repr

structure Input where
  name        : String
  email       : String
  phone       : String
  purchaseHistory : List String
  confirmedOrders : List String
  deriving DecidableEq, Repr

structure Output where
  profileCreated : Bool
  profile        : CustomerProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ "" ∧ i.phone ≠ ""
  post := fun i o => (o.profileCreated = true ↔
    o.profile.name = i.name ∧ o.profile.email = i.email ∧ o.profile.phone = i.phone ∧
    o.profile.purchaseHistory = i.purchaseHistory ∧
    o.profile.confirmedOrders = i.confirmedOrders) ∧
    (o.profileCreated = false ↔
      (o.profile.purchaseHistory = [] ∧ o.profile.confirmedOrders = []))

example : Spec.pre { name := "a", email := "alice@example.com", phone := "1234567890", purchaseHistory := [], confirmedOrders := [] } ∧ Spec.post { name := "a", email := "alice@example.com", phone := "1234567890", purchaseHistory := [], confirmedOrders := [] } { profileCreated := false, profile := { name := "Alice", email := "alice@example.com", phone := "1234567890", purchaseHistory := [], confirmedOrders := [] } } := by
  unfold Spec; decide
