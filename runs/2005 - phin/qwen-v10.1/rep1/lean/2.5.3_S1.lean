import ContractForge
open ContractForge

-- 2.5.3/S1: Systems supporting OM must be able to create and send messages for laboratory test requests.
-- compiles: True · rejects_bad_example: True · checked: True

structure TestRequest where
  patientID : Nat
  testCode  : String
  priority  : Nat
  deriving DecidableEq, Repr

structure Message where
  patientID : Nat
  testCode  : String
  priority  : Nat
  sent      : Bool
  deriving DecidableEq, Repr

structure Input where
  patientID : Nat
  testCode  : String
  priority  : Nat
  deriving DecidableEq, Repr

structure Output where
  sent      : Bool
  patientID : Nat
  testCode  : String
  priority  : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.patientID ≠ 0 ∧ i.testCode ≠ "" ∧ 1 ≤ i.priority
  post := fun i o => o.sent = true ∧
                     o.patientID = i.patientID ∧
                     o.testCode = i.testCode ∧
                     o.priority = i.priority

example : Spec.pre { patientID := 123, testCode := "A1", priority := 1 } ∧
          Spec.post { patientID := 123, testCode := "A1", priority := 1 }
                    { sent := true, patientID := 123, testCode := "A1", priority := 1 } := by
  unfold Spec; decide
