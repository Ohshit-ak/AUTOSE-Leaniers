import ContractForge
open ContractForge

-- 5.4.7/S1: Upon activation of the registration function, a USSD message (see section 11) shall be sent by the Cab radio.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  registrationActivated : Bool
  deriving DecidableEq, Repr

structure Output where
  ussdSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.registrationActivated = true
  post := fun i o => o.ussdSent = true ∧
                     (o.ussdSent = i.registrationActivated)

example : Spec.pre { registrationActivated := true } ∧
          Spec.post { registrationActivated := true } { ussdSent := true } := by
  unfold Spec; decide
