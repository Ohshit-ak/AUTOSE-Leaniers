import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.
-- compiles: False · rejects_bad_example: None · checked: False

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  action   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.signedIn = true ↔ i.action = "login" ∧
    ∃ a ∈ i.username, a.username = i.username ∧ a.password = i.password) ∧
                     (o.signedIn = false ↔ i.action = "register" ∧
                      ∀ a ∈ i.username, a.username ≠ i.username) ∧
                     (o.message = "Login successful." ↔ o.signedIn = true) ∧
                     (o.message = "Registration successful." ↔ o.signedIn = true) ∧
                     (o.message = "Invalid username or password." ↔ o.signedIn = false) ∧
                     (o.message = "User already exists." ↔ o.signedIn = false)

example : Spec.pre { username := "john", password := "pass123", action := "login" } ∧
          Spec.post { username := "john", password := "pass123", action := "login" }
                    { signedIn := true, message := "Login successful." } := by
  unfold Spec; decide

example : Spec.pre { username := "jane", password := "pass456", action := "register" } ∧
          Spec.post { username := "jane", password := "pass456", action := "register" }
                    { signedIn := true, message := "Registration successful." } := by
  unfold Spec; decide

example : Spec.pre { username := "jane", password := "pass456", action := "login" } ∧
          Spec.post { username := "jane", password := "pass456", action := "login" }
                    { signedIn := false, message := "Invalid username or password." } := by
  unfold Spec; decide

example : Spec.pre { username := "jane", password := "pass456", action := "register" } ∧
          Spec.post { username := "jane", password := "pass456", action := "register" }
                    { signedIn := false, message := "User already exists." } := by
  unfold Spec; decide
