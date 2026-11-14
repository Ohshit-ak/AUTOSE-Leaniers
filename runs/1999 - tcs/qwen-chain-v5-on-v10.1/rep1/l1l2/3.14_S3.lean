import ContractForge
open ContractForge

-- 3.14/S3: TCS training and training support shall include the processes, procedures, techniques, training devices and equipment to train civilian, active duty and reserve military personnel to operate and support the TCS system. [SSS491] This will include: individual and crew training; new equipment training; initial, formal, and on-the-job training.

-- L0 spec

structure Input where
  personnelType : String
  trainingType  : String
  deriving DecidableEq, Repr

structure Output where
  trainingComplete : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.personnelType ∈ ["civilian", "active duty", "reserve military"] ∧
                   i.trainingType ∈ ["individual", "crew", "new equipment", "initial", "formal", "on-the-job"]
  post := fun i o => (o.trainingComplete = true ↔
                      (i.personnelType = "civilian" →
                       (i.trainingType = "individual" ∨ i.trainingType = "new equipment" ∨
                        i.trainingType = "initial" ∨ i.trainingType = "formal" ∨
                        i.trainingType = "on-the-job")) ∧
                      (i.personnelType = "active duty" →
                       (i.trainingType = "individual" ∨ i.trainingType = "new equipment" ∨
                        i.trainingType = "initial" ∨ i.trainingType = "formal" ∨
                        i.trainingType = "on-the-job") ∧
                       ¬(i.personnelType = "active duty" ∧ i.trainingType = "crew"))) ∧
                     (i.personnelType = "reserve military" →
                      (i.trainingType = "individual" ∨ i.trainingType = "crew" ∨
                       i.trainingType = "new equipment" ∨ i.trainingType = "initial" ∨
                       i.trainingType = "formal" ∨ i.trainingType = "on-the-job"))

example : Spec.pre { personnelType := "active duty", trainingType := "formal" } ∧
          Spec.post { personnelType := "active duty", trainingType := "formal" }
                    { trainingComplete := true } := by
  unfold Spec; decide

example : Spec.pre { personnelType := "active duty", trainingType := "crew" } ∧
          Spec.post { personnelType := "active duty", trainingType := "crew" }
                    { trainingComplete := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { trainingComplete := decide ((x.personnelType = "civilian" →
                       (x.trainingType = "individual" ∨ x.trainingType = "new equipment" ∨
                        x.trainingType = "initial" ∨ x.trainingType = "formal" ∨
                        x.trainingType = "on-the-job")) ∧
                      (x.personnelType = "active duty" →
                       (x.trainingType = "individual" ∨ x.trainingType = "new equipment" ∨
                        x.trainingType = "initial" ∨ x.trainingType = "formal" ∨
                        x.trainingType = "on-the-job") ∧
                       ¬(x.personnelType = "active duty" ∧ x.trainingType = "crew"))) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
