import ContractForge
open ContractForge

-- 3.14/S3: TCS training and training support shall include the processes, procedures, techniques, training devices and equipment to train civilian, active duty and reserve military personnel to operate and support the TCS system. [SSS491] This will include: individual and crew training; new equipment training; initial, formal, and on-the-job training.
-- compiles: True · rejects_bad_example: True · checked: True

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
                      (i.personnelType = "civilian" ∧
                       (i.trainingType = "individual" ∨ i.trainingType = "new equipment" ∨
                        i.trainingType = "initial" ∨ i.trainingType = "formal" ∨
                        i.trainingType = "on-the-job")) ∨
                      (i.personnelType = "active duty" ∧
                       (i.trainingType = "individual" ∨ i.trainingType = "new equipment" ∨
                        i.trainingType = "initial" ∨ i.trainingType = "formal" ∨
                        i.trainingType = "on-the-job")) ∨
                      (i.personnelType = "reserve military" ∧
                       (i.trainingType = "individual" ∨ i.trainingType = "crew" ∨
                        i.trainingType = "new equipment" ∨ i.trainingType = "initial" ∨
                        i.trainingType = "formal" ∨ i.trainingType = "on-the-job"))) ∧
                     (o.trainingComplete = false ↔
                      (i.personnelType = "active duty" ∧ i.trainingType = "crew"))

example : Spec.pre { personnelType := "civilian", trainingType := "initial" } ∧
          Spec.post { personnelType := "civilian", trainingType := "initial" }
                    { trainingComplete := true } := by
  unfold Spec; decide

example : Spec.pre { personnelType := "active duty", trainingType := "crew" } ∧
          Spec.post { personnelType := "active duty", trainingType := "crew" }
                    { trainingComplete := false } := by
  unfold Spec; decide
