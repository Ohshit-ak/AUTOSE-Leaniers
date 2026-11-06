import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.

-- L0 spec

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  account  : Account
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" -- Customer account must be registered
  post := fun i o => (o.logged = true ↔ i.password = i.account.password) ∧
                     (o.logged = false ↔ i.password ≠ i.account.password) ∧
                     (o.cookie ≠ "" ↔ o.logged = true)

example : Spec.pre { username := "john", password := "pass123", email := "john@example.com", account := { username := "john", password := "pass123", email := "john@example.com" } } ∧ Spec.post { username := "john", password := "pass123", email := "john@example.com", account := { username := "john", password := "pass123", email := "john@example.com" } } { logged := true, cookie := "abc123" } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  account  : Account
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" -- Customer account must be registered
  post := fun i o => (o.logged = true ↔ i.password = i.account.password) ∧
                     (o.logged = false ↔ i.password ≠ i.account.password) ∧
                     (o.cookie ≠ "" ↔ o.logged = true)

-- Component 1: Check if the email is valid
def CheckEmailContract : Contract Input Bool := 
  <|
    pre  := fun i => i.email ≠ ""
    post := fun i b => b
  <| 

-- Component 2: Verify the password and generate the cookie if correct
def VerifyPasswordContract : Contract Bool Output := 
  <|
    pre  := fun b => b
    post := fun b o => (o.logged = true ↔ b) ∧
                       (o.logged = false ↔ ¬b) ∧
                       (o.cookie ≠ "" ↔ o.logged = true)
  <| 

-- Prove PO1: CheckEmailContract's postcondition is compatible with Spec's precondition
example : Contract.Compatible (CheckEmailContract.pre ∘ Spec.pre) (CheckEmailContract.post ∘ Spec.post) := by
  discharge_po

-- Prove PO2: VerifyPasswordContract's postcondition refines Spec's postcondition
example : Contract.Refines (CheckEmailContract.post ∘ Spec.post).seq VerifyPasswordContract Spec := by
  discharge_po

-- Prove PO1: VerifyPasswordContract's postcondition is compatible with CheckEmailContract's postcondition
example : Contract.Compatible (VerifyPasswordContract.pre ∘ CheckEmailContract.post) (VerifyPasswordContract.post ∘ CheckEmailContract.post) := by
  discharge_po

-- Prove PO2: The composition of the contracts refines the spec
example : Contract.Refines (CheckEmailContract.post ∘ Spec.post).seq VerifyPasswordContract Spec := by
  discharge_po