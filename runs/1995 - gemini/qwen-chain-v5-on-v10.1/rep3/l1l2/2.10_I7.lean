import ContractForge
open ContractForge

-- 2.10/I7: The control software should know what subsystems are installed and their status at all times.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { subsystems := x.subsystems }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
