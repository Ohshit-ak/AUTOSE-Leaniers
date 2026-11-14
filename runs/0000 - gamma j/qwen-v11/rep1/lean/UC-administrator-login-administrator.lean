import ContractForge
open ContractForge

-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- compiles: True · rejects_bad_example: False · checked: False

structure Account where
  username : String
  password : String
  email    : String
  role     : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  loggedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => ∃ a ∈ i.accounts, a.role = "Administrator" ∧ a.username = i.username ∧ a.password = i.password
  post := fun i o => o.loggedIn = true ∧
                     (o.cookie ≠ "" ↔ i.accounts.any (fun a => a.username = i.username ∧ a.password = i.password))

example : Spec.pre { accounts := [{ username := "admin", password := "pass", email := "admin@example.com", role := "Administrator" }],
                     username := "admin", password := "pass" } ∧
          Spec.post { accounts := [{ username := "admin", password := "pass", email := "admin@example.com", role := "Administrator" }],
                      username := "admin", password := "pass" }
                    { loggedIn := true, cookie := "session-cookie" } := by
  unfold Spec; decide
