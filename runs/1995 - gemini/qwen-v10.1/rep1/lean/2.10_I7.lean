import ContractForge
open ContractForge

-- 2.10/I7: The control software should know what subsystems are installed and their status at all times.
-- compiles: True · rejects_bad_example: None · checked: True

structure Subsystem where
  name : String
  status : String
  deriving DecidableEq, Repr

structure Input where
  subsystems : List Subsystem
  deriving DecidableEq, Repr

structure Output where
  subsystems : List Subsystem
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.subsystems.Nodup
  post := fun i o => o.subsystems = i.subsystems

example : Spec.pre { subsystems := [{ name := "Sub1", status := "active" },
                                     { name := "Sub2", status := "inactive" }] } ∧
          Spec.post { subsystems := [{ name := "Sub1", status := "active" },
                                     { name := "Sub2", status := "inactive" }] }
                    { subsystems := [{ name := "Sub1", status := "active" },
                                     { name := "Sub2", status := "inactive" }] } := by
  unfold Spec; decide
