import ContractForge
open ContractForge

-- 2.1.1.2.1.1/S1: A user with admin privileges shall be able to Add/Create a new user and associate the user with specified role(s) in the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Role where
  name : String
  deriving DecidableEq, Repr

structure User where
  username : String
  password : String
  roles    : List Role
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  roles    : List Role
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  user    : User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.roles.Nodup
  post := fun i o => (o.success = true ↔
    ∃ r ∈ i.roles, r.name ≠ "" ∧
    o.user = { username := i.username, password := i.password, roles := i.roles })

example : Spec.pre { username := "admin", password := "pass123", roles := [{ name := "admin" }] } ∧
          Spec.post { username := "admin", password := "pass123", roles := [{ name := "admin" }] }
                    { success := true, user := { username := "admin", password := "pass123", roles := [{ name := "admin" }] } } := by
  unfold Spec; decide
