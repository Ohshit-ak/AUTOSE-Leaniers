import ContractForge
open ContractForge

-- 3.1.3/S1: Customers will be able to create accounts to store their customer profiles, configure contact information, view their purchase history, and confirm orders.
-- compiles: True · rejects_bad_example: True · checked: True

structure CustomerProfile where
  name     : String
  email    : String
  address  : String
  deriving DecidableEq, Repr

structure PurchaseHistory where
  date     : String
  product  : String
  quantity : Nat
  deriving DecidableEq, Repr

structure Account where
  name        : String
  email       : String
  password    : String
  profile     : CustomerProfile
  history     : List PurchaseHistory
  orderStatus : List String
  deriving DecidableEq, Repr

structure Input where
  name        : String
  email       : String
  password    : String
  profile     : CustomerProfile
  history     : List PurchaseHistory
  orderStatus : List String
  passwordCorrect : Bool
  deriving DecidableEq, Repr

structure Output where
  account    : Account
  message    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.message = "Account created successfully." ↔
    i.passwordCorrect) ∧
                     (o.message = "Incorrect password." ↔
    ¬i.passwordCorrect) ∧
                     o.account.name = i.name ∧
                     o.account.email = i.email ∧
                     o.account.password = i.password ∧
                     o.account.profile = i.profile ∧
                     o.account.history = i.history ∧
                     o.account.orderStatus = i.orderStatus

example : Spec.pre { name := "John Doe", email := "johndoe@example.com", password := "password123", profile := { name := "John Doe", email := "johndoe@example.com", address := "123 Main St" }, history := [], orderStatus := [], passwordCorrect := true } ∧
          Spec.post { name := "John Doe", email := "johndoe@example.com", password := "password123", profile := { name := "John Doe", email := "johndoe@example.com", address := "123 Main St" }, history := [], orderStatus := [], passwordCorrect := true }
                    { account := { name := "John Doe", email := "johndoe@example.com", password := "password123", profile := { name := "John Doe", email := "johndoe@example.com", address := "123 Main St" }, history := [], orderStatus := [] }, message := "Account created successfully." } := by
  unfold Spec; decide

example : Spec.pre { name := "John Doe", email := "johndoe@example.com", password := "wrongpassword", profile := { name := "John Doe", email := "johndoe@example.com", address := "123 Main St" }, history := [], orderStatus := [], passwordCorrect := false } ∧
          Spec.post { name := "John Doe", email := "johndoe@example.com", password := "wrongpassword", profile := { name := "John Doe", email := "johndoe@example.com", address := "123 Main St" }, history := [], orderStatus := [], passwordCorrect := false }
                    { account := { name := "John Doe", email := "johndoe@example.com", password := "wrongpassword", profile := { name := "John Doe", email := "johndoe@example.com", address := "123 Main St" }, history := [], orderStatus := [] }, message := "Incorrect password." } := by
  unfold Spec; decide
