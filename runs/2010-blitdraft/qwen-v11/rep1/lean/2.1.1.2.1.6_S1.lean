import ContractForge
open ContractForge

-- 2.1.1.2.1.6/S1: The user record shall inherit all specified role(s) settings in the template when the user record is created from the user template
-- compiles: False · rejects_bad_example: None · checked: False

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
  newRecord : User
  deriving DecidableEq, Repr

structure Output where
  newRecord : User
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.newRecord = i.newRecord ∧
                     o.newRecord.roles.length = i.template.roles.length ∧
                     ∀ r ∈ o.newRecord.roles, r.settings = i.template.roles.find? r.name.getD ""

example : Spec.pre { template := { name := "admin", roles := [{ name := "admin", settings := "setting1" }] },
                     newRecord := { name := "newAdmin", roles := [{ name := "admin", settings := "setting1" }] } } ∧
          Spec.post { template := { name := "admin", roles := [{ name := "admin", settings := "setting1" }] },
                      newRecord := { name := "newAdmin", roles := [{ name := "admin", settings := "setting1" }] } }
                    { newRecord := { name := "newAdmin", roles := [{ name := "admin", settings := "setting1" }] } } := by
  unfold Spec; decide
