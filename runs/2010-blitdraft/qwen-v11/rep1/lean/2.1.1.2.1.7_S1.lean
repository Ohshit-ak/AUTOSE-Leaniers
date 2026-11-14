import ContractForge
open ContractForge

-- 2.1.1.2.1.7/S1: The user shall be able to add additional roles manually while creating/adding a new user from a user template.
-- compiles: True · rejects_bad_example: True · checked: True

structure Role where
  name : String
  deriving DecidableEq, Repr

structure User where
  username : String
  roles    : List Role
  deriving DecidableEq, Repr

structure Input where
  templateUser : User
  additionalRoles : List Role
  deriving DecidableEq, Repr

structure Output where
  newUser : User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.templateUser.username ≠ "" ∧ i.additionalRoles.Nodup
  post := fun i o => o.newUser.username = i.templateUser.username ∧
                     o.newUser.roles = i.templateUser.roles ++ i.additionalRoles

example : Spec.pre { templateUser := { username := "john", roles := [] },
                     additionalRoles := [{ name := "admin" }, { name := "editor" }] } ∧
          Spec.post { templateUser := { username := "john", roles := [] },
                      additionalRoles := [{ name := "admin" }, { name := "editor" }] }
                    { newUser := { username := "john", roles := [{ name := "admin" }, { name := "editor" }] } } := by
  unfold Spec; decide
