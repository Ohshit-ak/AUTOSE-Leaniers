import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- compiles: True · rejects_bad_example: True · checked: True

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  registered : List Account
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  failedAttempts : Nat
  message : String
  deriving DecidableEq, Repr

-- A username is valid if it is non-empty and consists only of alphanumeric characters.
def ValidUsername (u : String) : Bool :=
  u ≠ "" ∧ u.toList.all (·.isAlphanum)

-- A password is valid if it is non-empty.
def ValidPassword (p : String) : Bool :=
  p ≠ ""

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ ValidUsername i.username ∧ ValidPassword i.password
  post := fun i o => o.logged = true ↔
    (i.username ≠ "" ∧ ValidUsername i.username ∧ ValidPassword i.password) ∧
    (o.failedAttempts = i.failedAttempts + 1 ↔ o.message = "Failed login attempt.") ∧
    (o.message = "Account registered." ↔ o.failedAttempts = 0) ∧
    (o.message = "Logged in." ↔ o.logged = true) ∧
    (o.message = "Logged out." ↔ o.logged = false) ∧
    (o.logged = true ↔ ∃ a ∈ i.registered, a.username = i.username) ∧
    (o.failedAttempts = i.failedAttempts + 1 ↔ o.message = "Failed login attempt.") ∧
    (o.failedAttempts = i.failedAttempts ↔ o.message = "Logged out.")

example : Spec.pre { username := "johnDoe", password := "password123", registered := [], failedAttempts := 0 } ∧ Spec.post { username := "johnDoe", password := "password123", registered := [], failedAttempts := 0 } { logged := false, failedAttempts := 1, message := "Failed login attempt." } := by
  unfold Spec; decide
