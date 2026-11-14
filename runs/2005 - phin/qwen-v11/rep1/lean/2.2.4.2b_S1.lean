import ContractForge
open ContractForge

-- 2.2.4.2b/S1: There must be a means to update the case diagnosis either manually or automatically if the case definition changes during an event.
-- compiles: True · rejects_bad_example: True · checked: True

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
