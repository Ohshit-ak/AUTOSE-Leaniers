import ContractForge
open ContractForge

-- 4/access-module/R6: The System must allow changes to security attributes for groups or users (such as access rights, security level, privileges, password allocation and management) to be made only by super-user.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  superUser : Bool
  group     : String
  user      : String
  deriving DecidableEq, Repr

structure Output where
  changed  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.superUser
  post := fun i o => (o.changed = true ↔
    (i.group ≠ "" ∨ i.user ≠ ""))

example : Spec.pre { superUser := true, group := "admin", user := "" } ∧
          Spec.post { superUser := true, group := "admin", user := "" }
                    { changed := true } := by
  unfold Spec; decide
