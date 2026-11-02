import ContractForge
open ContractForge

-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- compiles: True · rejects_bad_example: None · checked: False

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.accounts.Nodup ∧
                  ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password
  post := fun i o => o.signedIn = true ∧
                     (o.cookie ≠ "" ↔ i.accounts.any (fun a => a.username = i.username)) ∧
                     (o.signedIn = true → o.cookie ≠ "")

example : Spec.pre { accounts := [{ username := "admin", password := "pass123", email := "admin@example.com" }],
                     username := "admin", password := "pass123" } ∧
          Spec.post { accounts := [{ username := "admin", password := "pass123", email := "admin@example.com" }],
                      username := "admin", password := "pass123" }
                    { signedIn := true, cookie := "session123" } := by
  unfold Spec; decide
