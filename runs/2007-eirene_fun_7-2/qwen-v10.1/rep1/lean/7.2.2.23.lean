import ContractForge
open ContractForge

-- 7.2.2.23: 7.2.2.23 Reception of this call shall proceed as for a standard group or broadcast call except that a distinctive audible and visual indication shall be provided. (M) Terminate calls
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  callType : String
  deriving DecidableEq, Repr

structure Output where
  callTerminated : Bool
  indicationProvided : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callType = "operational radio"
  post := fun i o => o.callTerminated = true ∧
                     (o.indicationProvided = true ↔
                      i.callType = "standard group or broadcast call")

example : Spec.pre { callType := "operational radio" } ∧ Spec.post { callType := "operational radio" } { callTerminated := true, indicationProvided := false } := by
  unfold Spec; decide
