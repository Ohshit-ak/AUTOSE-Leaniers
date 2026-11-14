import ContractForge
open ContractForge

-- 2.5.3/S1: Systems supporting OM must be able to create and send messages for laboratory test requests.
-- compiles: True · rejects_bad_example: True · checked: True

structure TestRequest where
  patientID : Nat
  testCode  : String
  results   : Option String
  deriving DecidableEq, Repr

structure Input where
  patientID : Nat
  testCode  : String
  results   : Option String
  send      : Bool
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  messageID : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.patientID ≠ 0 ∧ i.testCode ≠ "" ∧ i.send
  post := fun i o => (o.sent = true ↔ i.results.isSome) ∧
                     (o.sent = false ↔ i.results.isNone) ∧
                     (o.sent = true → o.messageID ≠ 0)

example : Spec.pre { patientID := 123, testCode := "TEST123", results := some "Positive", send := true } ∧
          Spec.post { patientID := 123, testCode := "TEST123", results := some "Positive", send := true }
                    { sent := true, messageID := 456 } := by
  unfold Spec; decide

example : Spec.pre { patientID := 123, testCode := "TEST123", results := none, send := true } ∧
          Spec.post { patientID := 123, testCode := "TEST123", results := none, send := true }
                    { sent := false, messageID := 0 } := by
  unfold Spec; decide
