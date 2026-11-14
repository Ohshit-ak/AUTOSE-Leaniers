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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { profileCreated := true,
    profile := { name := x.name, email := x.email, phone := x.phone, address := x.address, purchaseHistory := x.purchaseHistory, orderStatus := x.orderStatus } }
