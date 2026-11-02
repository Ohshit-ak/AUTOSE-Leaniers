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
  current : User
  newProps : User
  deriving DecidableEq, Repr

structure Output where
  altered : User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.current.privileges ≥ 1
  post := fun i o => o.altered.username = i.current.username ∧
                      o.altered.password = i.newProps.password ∧
                      o.altered.privileges = i.newProps.privileges

example : Spec.pre { current := { username := "admin", password := "admin123", privileges := 5 },
                     newProps := { username := "admin", password := "newpass123", privileges := 5 } } ∧
          Spec.post { current := { username := "admin", password := "admin123", privileges := 5 },
                      newProps := { username := "admin", password := "newpass123", privileges := 5 } }
                    { altered := { username := "admin", password := "newpass123", privileges := 5 } } := by
  unfold Spec; decide
