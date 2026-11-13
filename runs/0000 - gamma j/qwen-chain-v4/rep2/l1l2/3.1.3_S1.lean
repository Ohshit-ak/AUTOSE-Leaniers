import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.

-- L0 spec

structure CustomerProfile where
  name        : String
  email       : String
  phone       : String
  address     : String
  purchaseHistory : List String
  orderStatus : String
  deriving DecidableEq, Repr

structure Input where
  name        : String
  email       : String
  phone       : String
  address     : String
  purchaseHistory : List String
  orderStatus : String
  deriving DecidableEq, Repr

structure Output where
  profileCreated : Bool
  profile        : CustomerProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" ∧ i.phone ≠ "" ∧ i.address ≠ ""
  post := fun i o => (o.profileCreated = true ↔
    o.profile.name = i.name ∧ o.profile.email = i.email ∧
    o.profile.phone = i.phone ∧ o.profile.address = i.address ∧
    o.profile.purchaseHistory = i.purchaseHistory ∧
    o.profile.orderStatus = i.orderStatus) ∧
    o.profile.purchaseHistory.Nodup ∧
    o.profile.orderStatus = "confirmed"

example : Spec.pre { name := "John Doe", email := "johndoe@example.com", phone := "1234567890", address := "123 Main St", purchaseHistory := [], orderStatus := "confirmed" } ∧
          Spec.post { name := "John Doe", email := "johndoe@example.com", phone := "1234567890", address := "123 Main St", purchaseHistory := [], orderStatus := "confirmed" }
                    { profileCreated := true, profile := { name := "John Doe", email := "johndoe@example.com", phone := "1234567890", address := "123 Main St", purchaseHistory := [], orderStatus := "confirmed" } } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  name        : String
  email       : String
  phone       : String
  address     : String
  purchaseHistory : List String
  orderStatus : String
  profileCreated : Bool
  deriving DecidableEq, Repr

def CreateProfileContract : Contract Input Mid where
  pre  := fun i => i.email ≠ "" ∧ i.phone ≠ "" ∧ i.address ≠ ""
  post := fun i m => m.name = i.name ∧ m.email = i.email ∧ m.phone = i.phone ∧ m.address = i.address ∧ m.purchaseHistory = i.purchaseHistory ∧ m.orderStatus = i.orderStatus ∧ m.profileCreated = true

def ConfirmProfileContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.profileCreated = m.profileCreated ∧
                     o.profile.name = m.name ∧ o.profile.email = m.email ∧
                     o.profile.phone = m.phone ∧ o.profile.address = m.address ∧
                     o.profile.purchaseHistory = m.purchaseHistory ∧
                     o.profile.orderStatus = m.orderStatus ∧
                     o.profile.purchaseHistory.Nodup ∧
                     o.profile.orderStatus = "confirmed"
