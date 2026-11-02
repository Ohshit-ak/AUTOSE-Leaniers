import ContractForge
open ContractForge

-- UC-administrator-login-administrator: Login Administrator: Login to an Administrator account with the system.
-- compiles: True · rejects_bad_example: None · checked: False

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
  username : String
  role     : String
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                  ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password ∧ a.role = "Administrator"
  post := fun i o => o.username = i.username ∧
                     o.role = "Administrator" ∧
                     o.cookie ≠ ""

example : Spec.pre { accounts := [{ username := "admin", password := "pass", email := "admin@example.com", role := "Administrator" }],
                     username := "admin", password := "pass" } ∧
          Spec.post { accounts := [{ username := "admin", password := "pass", email := "admin@example.com", role := "Administrator" }],
                      username := "admin", password := "pass" }
                    { username := "admin", role := "Administrator", cookie := "cookie123" } := by
  unfold Spec; decide
