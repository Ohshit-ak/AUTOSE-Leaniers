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
  username : String
  role     : String
  session  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.username = i.username ∧ o.role = "Administrator") ↔
                     (i.username = "admin" ∧ i.password = "password" ∧
                      ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password)

example : Spec.pre { username := "admin", password := "password" } ∧
          Spec.post { username := "admin", password := "password", session := "cookie123" }
                    { username := "admin", role := "Administrator", session := "cookie123" } := by
  unfold Spec; decide
