import ContractForge
open ContractForge

-- 4/access-module/R6: The System must allow changes to security attributes for groups or users (such as access rights, security level, privileges, password allocation and management) to be made only by super-user.
-- compiles: True · rejects_bad_example: None · checked: True

structure SecurityAttribute where
  user : String
  privilege : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  user : String
  privilege : String
  password : String
  isSuperUser : Bool
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isSuperUser
  post := fun i o => o.success ↔
    (i.isSuperUser = true ∧
     (i.privilege = "change_security_attributes" ∨
      i.privilege = "super_user"))

example : Spec.pre { user := "admin", privilege := "change_security_attributes", password := "pass", isSuperUser := true } ∧
          Spec.post { user := "admin", privilege := "change_security_attributes", password := "pass", isSuperUser := true }
                    { success := true } := by
  unfold Spec; decide
