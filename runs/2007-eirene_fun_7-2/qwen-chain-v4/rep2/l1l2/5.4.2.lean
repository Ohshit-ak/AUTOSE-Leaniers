import ContractForge
open ContractForge

-- 5.4.2: 5.4.2 Radio equipment installed in a drivers Cab shall not obstruct the drivers vision or otherwise hinder the safe driving of the train. (M)

-- L0 spec

structure Input where
  radioObstructsVision : Bool
  deriving DecidableEq, Repr

structure Output where
  safeToDrive : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.radioObstructsVision = false
  post := fun i o => o.safeToDrive = true ↔ i.radioObstructsVision = false

example : Spec.pre { radioObstructsVision := false } ∧
          Spec.post { radioObstructsVision := false }
                    { safeToDrive := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { safeToDrive := decide (x.radioObstructsVision = false) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
