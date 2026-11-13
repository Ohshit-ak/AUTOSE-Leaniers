import ContractForge
open ContractForge

-- 5.7.4: 5.7.4 DSD alarm information shall be transmitted to the primary controller. (M)

-- L0 spec

structure Input where
  alarmInfo : String
  deriving DecidableEq, Repr

structure Output where
  primaryController : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.primaryController = i.alarmInfo

example : Spec.pre { alarmInfo := "DSD alarm" } ∧
          Spec.post { alarmInfo := "DSD alarm" } { primaryController := "DSD alarm" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { primaryController := x.alarmInfo }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
