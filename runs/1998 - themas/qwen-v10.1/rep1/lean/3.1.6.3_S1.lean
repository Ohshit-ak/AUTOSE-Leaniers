import ContractForge
open ContractForge

-- 3.1.6.3/S1: This process shall recognize the values for the requested heating or cooling unit and the ON or OFF status that is being requested.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  unitId : Nat
  requestedStatus : String
  deriving DecidableEq, Repr

structure Output where
  unitId : Nat
  status : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.requestedStatus = "ON" ∨ i.requestedStatus = "OFF"
  post := fun i o => o.unitId = i.unitId ∧
                     (o.status = "ON" ↔ i.requestedStatus = "ON") ∧
                     (o.status = "OFF" ↔ i.requestedStatus = "OFF")

example : Spec.pre { unitId := 123, requestedStatus := "ON" } ∧
          Spec.post { unitId := 123, requestedStatus := "ON" }
                    { unitId := 123, status := "ON" } := by
  unfold Spec; decide
