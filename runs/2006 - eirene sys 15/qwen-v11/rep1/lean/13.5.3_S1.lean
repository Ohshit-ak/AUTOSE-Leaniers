import ContractForge
open ContractForge

-- 13.5.3/S1: Confirmation of Railway emergency calls shall be implemented using the User to User Signalling supplementary service (UUS1).
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  callId : Nat
  emergency : Bool
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

-- IMPL: User to User Signalling supplementary service (UUS1)
def Spec : Contract Input Output where
  pre  := fun i => i.emergency = true
  post := fun i o => o.confirmed = i.emergency

example : Spec.pre { callId := 123, emergency := true } ∧
          Spec.post { callId := 123, emergency := true } { confirmed := true } := by
  unfold Spec; decide
