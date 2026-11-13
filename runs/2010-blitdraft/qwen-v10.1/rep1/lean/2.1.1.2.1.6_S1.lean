import ContractForge
open ContractForge

-- 2.1.1.2.1.6/S1: The user record shall inherit all specified role(s) settings in the template when the user record is created from the user template
-- compiles: True · rejects_bad_example: None · checked: True

structure Role where
  name : String
  settings : String
  deriving DecidableEq, Repr

structure User where
  name : String
  roles : List Role
  deriving DecidableEq, Repr

structure Input where
  template : User
  newRoles : List Role
  deriving DecidableEq, Repr

structure Output where
  user : User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.template.name ≠ "" ∧ i.newRoles.Nodup
  post := fun i o => o.user.name = i.template.name ∧
                     o.user.roles = i.template.roles ++ i.newRoles

example : Spec.pre { template := { name := "Alice", roles := [{ name := "admin", settings := "high" }] },
                     newRoles := [{ name := "user", settings := "medium" }] } ∧
          Spec.post { template := { name := "Alice", roles := [{ name := "admin", settings := "high" }] },
                      newRoles := [{ name := "user", settings := "medium" }] }
                    { user := { name := "Alice", roles := [{ name := "admin", settings := "high" }, { name := "user", settings := "medium" }] } } := by
  unfold Spec; decide
