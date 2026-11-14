import ContractForge
open ContractForge

-- 4.3.1/I2: flexibility to meet the dynamics of the organisational and legal changes and

-- L0 spec

structure Config where
  settings : List String
  deriving DecidableEq, Repr

structure Input where
  settings : List String
  deriving DecidableEq, Repr

structure Output where
  updatedSettings : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.settings.Nodup
  post := fun i o => o.updatedSettings = i.settings ++ (i.settings.filter (fun s => ¬ o.updatedSettings.contains s))

example : Spec.pre { settings := [] } ∧ Spec.post { settings := [] } { updatedSettings := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { updatedSettings := x.settings }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
