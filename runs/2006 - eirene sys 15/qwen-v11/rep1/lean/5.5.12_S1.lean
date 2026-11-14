import ContractForge
open ContractForge

-- 5.5.12/S1: Unless otherwise indicated at time of entry, calls from the stored numbers list shall be initiated as voice calls.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  callNumber : String
  callType   : Option String
  deriving DecidableEq, Repr

structure Output where
  callInitiated : Bool
  callType      : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callNumber ≠ ""
  post := fun i o => (o.callInitiated = true ↔
    (i.callType = none → o.callType = "voice") ∧
    (i.callType ≠ none → o.callType = i.callType.get!))

example : Spec.pre { callNumber := "1234567890", callType := none } ∧
          Spec.post { callNumber := "1234567890", callType := none }
                    { callInitiated := true, callType := "voice" } := by
  unfold Spec; decide
