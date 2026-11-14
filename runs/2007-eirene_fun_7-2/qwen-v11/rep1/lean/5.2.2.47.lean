import ContractForge
open ContractForge

-- 5.2.2.47: 5.2.2.47 An audible and visual indication of the incoming call shall be provided when a Cab radio receives a group or broadcast call. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  cabId : Nat
  callType : String
  deriving DecidableEq, Repr

structure Output where
  audibleIndication : Bool
  visualIndication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callType = "group" ∨ i.callType = "broadcast"
  post := fun i o => (o.audibleIndication = true ∧ o.visualIndication = true) ↔
                     (i.callType = "group" ∨ i.callType = "broadcast")

example : Spec.pre { cabId := 1, callType := "group" } ∧
          Spec.post { cabId := 1, callType := "group" }
                    { audibleIndication := true, visualIndication := true } := by
  unfold Spec; decide
