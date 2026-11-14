import ContractForge
open ContractForge

-- 4.1.1.3b: It shall also be possible, to allow the driver to change the adhesion conditions; in this case information from trackside has priority.

-- L0 spec

structure Input where
  adhesionConditions : String
  tracksideInfo      : String
  deriving DecidableEq, Repr

structure Output where
  adhesionConditions : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.adhesionConditions ≠ "" ∧ i.tracksideInfo ≠ ""
  post := fun i o => o.adhesionConditions = if i.tracksideInfo = i.adhesionConditions then i.adhesionConditions
                                                  else i.tracksideInfo

example : Spec.pre { adhesionConditions := "dry", tracksideInfo := "wet" } ∧
          Spec.post { adhesionConditions := "dry", tracksideInfo := "wet" }
                    { adhesionConditions := "wet" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { adhesionConditions := if x.tracksideInfo = x.adhesionConditions then x.adhesionConditions
                                                  else x.tracksideInfo }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
