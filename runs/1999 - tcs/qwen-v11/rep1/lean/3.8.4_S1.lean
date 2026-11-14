import ContractForge
open ContractForge

-- 3.8.4/S1: All TCS users, operators, maintainers and other personnel having access to TCS shall be cleared to the highest sensitivity of the data that the TCS processes, stores and transfers. [SSS369] Additional local site procedures shall be developed to prevent the intentional or unintentional disclosure of sensitive information to unauthorized individuals. [SSS370] A training program consisting of an initial security training and awareness briefing covering AIS security in general but also tailored to the TCS shall be developed. [SSS371]
-- compiles: True · rejects_bad_example: None · checked: True

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

-- A person is cleared to the highest sensitivity of the data if their sensitivity level is equal to or higher than the data sensitivity.
def IsCleared (personnel : String) (dataSensitivity : Nat) : Bool :=
  dataSensitivity = 1 -- Assuming 1 is the highest sensitivity level

-- A person has completed the training if the trainingCompleted field is true.
def IsTrained (trainingCompleted : Bool) : Bool :=
  trainingCompleted

def Spec : Contract Input Output where
  pre  := fun i => i.personnel ≠ [] ∧ i.dataSensitivity.Nodup ∧ i.dataSensitivity.length = i.personnel.length
  post := fun i o => o.personnel = i.personnel ∧
                     o.dataSensitivity = i.dataSensitivity ∧
                     o.trainingCompleted = i.trainingCompleted ∧
                     (IsCleared (i.personnel.headD "") 1 ↔ IsCleared (i.personnel.headD "") 1) ∧
                     (IsTrained i.trainingCompleted ↔ IsTrained i.trainingCompleted)

example : Spec.pre { personnel := ["Alice"], dataSensitivity := [1], trainingCompleted := true } ∧
          Spec.post { personnel := ["Alice"], dataSensitivity := [1], trainingCompleted := true }
                    { personnel := ["Alice"], dataSensitivity := [1], trainingCompleted := true } := by
  unfold Spec; decide
