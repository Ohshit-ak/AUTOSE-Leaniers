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
  username  : String
  password  : String
  roles     : List Role
  admin     : Bool
  deriving DecidableEq, Repr

structure Output where
  success   : Bool
  new_user  : User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.admin = true
  post := fun i o => o.success ↔
    (i.username ≠ "" ∧ i.password ≠ "" ∧ i.roles.Nodup ∧
     ∃ r ∈ i.roles, r.name = "admin") ∧
    o.new_user = { username := i.username, password := i.password, roles := i.roles }

example : Spec.pre { username := "admin", password := "pass", roles := [], admin := true } ∧ Spec.post { username := "admin", password := "pass", roles := [], admin := true } { success := false, new_user := { username := "admin", password := "pass", roles := [] } } := by
  unfold Spec; decide
