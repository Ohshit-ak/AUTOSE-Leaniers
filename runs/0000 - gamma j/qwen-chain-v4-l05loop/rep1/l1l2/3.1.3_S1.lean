import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.

-- L0 spec

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
    o.profile.purchaseHistory.Nodup ∧
    o.profile.confirmedOrders.Nodup

example : Spec.pre { name := "John Doe", email := "johndoe@example.com", phone := "1234567890",
                     purchaseHistory := [], confirmedOrders := [] } ∧
          Spec.post { name := "John Doe", email := "johndoe@example.com", phone := "1234567890",
                      purchaseHistory := [], confirmedOrders := [] }
                    { profileCreated := true, profile := { name := "John Doe", email := "johndoe@example.com",
                                                            phone := "1234567890", purchaseHistory := [], confirmedOrders := [] } } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  profile : CustomerProfile
  deriving DecidableEq, Repr

def CreateProfileContract : Contract Input Mid where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ "" ∧ i.phone ≠ ""
  post := fun i m => m.profile.name = i.name ∧ m.profile.email = i.email ∧ m.profile.phone = i.phone ∧
                     m.profile.purchaseHistory = i.purchaseHistory ∧
                     m.profile.confirmedOrders = i.confirmedOrders

def FinalizeProfileContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.profileCreated = true ↔ o.profile = m.profile) ∧
                     o.profile.purchaseHistory.Nodup ∧
                     o.profile.confirmedOrders.Nodup
