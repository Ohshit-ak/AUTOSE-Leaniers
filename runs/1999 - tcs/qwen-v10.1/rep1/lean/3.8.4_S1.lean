import ContractForge
open ContractForge

-- 3.8.4/S1: All TCS users, operators, maintainers and other personnel having access to TCS shall be cleared to the highest sensitivity of the data that the TCS processes, stores and transfers. [SSS369] Additional local site procedures shall be developed to prevent the intentional or unintentional disclosure of sensitive information to unauthorized individuals. [SSS370] A training program consisting of an initial security training and awareness briefing covering AIS security in general but also tailored to the TCS shall be developed. [SSS371]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  personnel : List String
  dataSensitivity : List Nat
  trainingCompleted : Bool
  deriving DecidableEq, Repr

structure Output where
  personnel : List String
  dataSensitivity : List Nat
  trainingCompleted : Bool
  deriving DecidableEq, Repr

-- A person is cleared to the highest sensitivity of the data if their sensitivity level is less than or equal to the highest sensitivity in the dataSensitivity list.
def IsCleared (personnel : List String) (dataSensitivity : List Nat) : Bool :=
  let maxSensitivity := dataSensitivity.maxOption.getD 0;
  personnel.all (fun p => dataSensitivity.any (fun s => s ≤ maxSensitivity))

-- A training program is considered complete if it has been completed.
def TrainingComplete (trainingCompleted : Bool) : Bool :=
  trainingCompleted

def Spec : Contract Input Output where
  pre  := fun i => IsCleared i.personnel i.dataSensitivity ∧ TrainingComplete i.trainingCompleted
  post := fun i o => o.personnel = i.personnel ∧ o.dataSensitivity = i.dataSensitivity ∧
                     o.trainingCompleted = i.trainingCompleted

example : Spec.pre { personnel := ["Alice", "Bob"], dataSensitivity := [3, 4, 5], trainingCompleted := true } ∧
          Spec.post { personnel := ["Alice", "Bob"], dataSensitivity := [3, 4, 5], trainingCompleted := true }
                    { personnel := ["Alice", "Bob"], dataSensitivity := [3, 4, 5], trainingCompleted := true } := by
  unfold Spec; decide
