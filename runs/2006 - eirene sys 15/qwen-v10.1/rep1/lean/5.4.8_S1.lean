import ContractForge
open ContractForge

-- 5.4.8/S1: Upon activation of the deregistration function, a USSD message (see section 11) shall be sent by the Cab radio.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  deregistered : Bool
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.deregistered = true
  post := fun i o => o.sent = true ∧ o.message = "USSD deregistration message"

example : Spec.pre { deregistered := true } ∧
          Spec.post { deregistered := true }
                    { sent := true, message := "USSD deregistration message" } := by
  unfold Spec; decide
