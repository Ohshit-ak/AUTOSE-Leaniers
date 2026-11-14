import ContractForge
open ContractForge

-- 2.5.10/S1: Systems supporting OM must be able to create and send messages for countermeasure administration requests.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  countermeasure : String
  patientID      : String
  dose           : Nat
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  messageID : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.countermeasure ≠ "" ∧ i.patientID ≠ "" ∧ 0 < i.dose
  post := fun i o => (o.sent = true ↔
    i.countermeasure = "vaccine" ∧ i.patientID.toList.all (fun c => c.isAlpha || c.isDigit) = true ∧ 0 < i.dose)

example : Spec.pre { countermeasure := "vaccine", patientID := "P12345", dose := 2 } ∧
          Spec.post { countermeasure := "vaccine", patientID := "P12345", dose := 2 }
                    { sent := true, messageID := "MSG12345" } := by
  unfold Spec; decide
