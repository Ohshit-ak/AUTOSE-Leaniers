import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.

-- L0 spec

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
    (o.message = "Login successful." ↔ o.failedAttempts = 0) ∧
    (o.failedAttempts = 0 → o.message = "Login successful.") ∧
    (o.logged = false ↔ o.failedAttempts > 0)

example : Spec.pre { username := "test", password := "wrong", registered := [], failedAttempts := 0 } ∧
  ¬ Spec.post { username := "test", password := "wrong", registered := [], failedAttempts := 0 } { logged := true, failedAttempts := 1, message := "Failed login attempt." } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { logged := false,
    failedAttempts := x.failedAttempts + 1,
    message := "Failed login attempt." }
