import ContractForge
open ContractForge

-- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.
-- compiles: True · rejects_bad_example: True · checked: True

structure User where
  username : String
  password : String
  privileges : Nat
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  privileges : Nat
  deriving DecidableEq, Repr

structure Output where
  username : String
  password : String
  privileges : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.username = i.username ∧
                     o.password = i.password ∧
                     o.privileges = i.privileges

example : Spec.pre { username := "admin", password := "pass123", privileges := 5 } ∧
          Spec.post { username := "admin", password := "pass123", privileges := 5 }
                    { username := "admin", password := "pass123", privileges := 5 } := by
  unfold Spec; decide
