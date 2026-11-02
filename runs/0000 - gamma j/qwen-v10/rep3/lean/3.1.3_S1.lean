import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- compiles: True · rejects_bad_example: True · checked: True

structure CustomerProfile where
  name        : String
  email       : String
  phone       : String
  address     : String
  purchaseHistory : List String
  orderConfirmed : Bool
  deriving DecidableEq, Repr

structure Input where
  name        : String
  email       : String
  phone       : String
  address     : String
  purchaseHistory : List String
  orderConfirmed : Bool
  deriving DecidableEq, Repr

structure Output where
  name        : String
  email       : String
  phone       : String
  address     : String
  purchaseHistory : List String
  orderConfirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ "" ∧ i.phone ≠ "" ∧ i.address ≠ ""
  post := fun i o => o.name = i.name ∧ o.email = i.email ∧ o.phone = i.phone ∧
                     o.address = i.address ∧ o.purchaseHistory = i.purchaseHistory ∧
                     o.orderConfirmed = i.orderConfirmed

example : Spec.pre { name := "John Doe", email := "johndoe@example.com", phone := "1234567890",
                     address := "123 Main St", purchaseHistory := [], orderConfirmed := false } ∧
          Spec.post { name := "John Doe", email := "johndoe@example.com", phone := "1234567890",
                      address := "123 Main St", purchaseHistory := [], orderConfirmed := false }
                    { name := "John Doe", email := "johndoe@example.com", phone := "1234567890",
                      address := "123 Main St", purchaseHistory := [], orderConfirmed := false } := by
  unfold Spec; decide
