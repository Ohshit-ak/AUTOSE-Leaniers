import ContractForge
open ContractForge

-- 2.2.4.2b/S1: There must be a means to update the case diagnosis either manually or automatically if the case definition changes during an event.

-- L0 spec

structure Case where
  diagnosis : String
  eventId   : Nat
  deriving DecidableEq, Repr

structure Input where
  diagnosis  : String
  newDiagnosis : String
  eventId    : Nat
  deriving DecidableEq, Repr

structure Output where
  diagnosis  : String
  eventId    : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.eventId > 0
  post := fun i o => o.diagnosis = i.newDiagnosis ∧ o.eventId = i.eventId

example : Spec.pre { diagnosis := "flu", newDiagnosis := "pneumonia", eventId := 1 } ∧
          Spec.post { diagnosis := "flu", newDiagnosis := "pneumonia", eventId := 1 }
                    { diagnosis := "pneumonia", eventId := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { diagnosis := x.newDiagnosis,
    eventId := x.eventId }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
