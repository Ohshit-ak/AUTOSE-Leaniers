import ContractForge
open ContractForge

-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- compiles: False · rejects_bad_example: None · checked: False

structure Account where
  username : String
  password : String
  email    : String
  role     : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => ∃ a ∈ i.accounts, a.role = "Administrator"
  post := fun i o => o.logged = true ∧
                     (o.cookie ≠ "" ↔ i.username = i.accounts.find? (fun a => a.role = "Administrator").get.username)

example : Spec.pre { accounts := [{ username := "admin1", password := "pass1", email := "a1@example.com", role := "Administrator" },
                                   { username := "user1", password := "pass2", email := "u1@example.com", role := "User" }] } ∧
          Spec.post { accounts := [{ username := "admin1", password := "pass1", email := "a1@example.com", role := "Administrator" },
                                    { username := "user1", password := "pass2", email := "u1@example.com", role := "User" }],
                      username := "admin1", password := "pass1" }
                    { logged := true, cookie := "abc123" } := by
  unfold Spec; decide
