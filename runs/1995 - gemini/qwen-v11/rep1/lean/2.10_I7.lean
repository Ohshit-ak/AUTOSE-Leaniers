import ContractForge
open ContractForge

-- 2.10/I7: The control software should know what subsystems are installed and their status at all times.
-- compiles: True · rejects_bad_example: True · checked: True

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
  pre  := fun i => i.subsystems.Nodup ∧
                  ∀ s ∈ i.subsystems, s.status = "active" ∨ s.status = "inactive"
  post := fun i o => o.subsystems = i.subsystems.filter (fun s => s.status = "active" ∨ s.status = "inactive")

example : Spec.pre { subsystems := [] } ∧ Spec.post { subsystems := [] } { subsystems := [] } := by
  unfold Spec; decide
