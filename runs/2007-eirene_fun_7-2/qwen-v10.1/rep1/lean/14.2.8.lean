import ContractForge
open ContractForge

-- 14.2.8: 14.2.8 Operational radios used for shunting shall be able to be switched between the following two operating modes by a maintenance function: (M) Mode 1: the member is required to continuously press the link assurance signal button in order to transmit the link assurance signal; Mode 2: the member is required to switch on the link assurance signal and then periodically press a button in order to transmit the link assurance signal (failure to do so shall result in the deactivation of the link assurance signal after a predefined period has elapsed).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mode : String
  linkAssuranceSignalPressed : Bool
  periodicButtonPressed : Bool
  deriving DecidableEq, Repr

structure Output where
  linkAssuranceSignalActive : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mode ∈ ["M", "2"]
  post := fun i o =>
    (i.mode = "M" → o.linkAssuranceSignalActive = i.linkAssuranceSignalPressed) ∧
    (i.mode = "2" →
      (o.linkAssuranceSignalActive = i.linkAssuranceSignalPressed ∧
       i.linkAssuranceSignalPressed →
       o.linkAssuranceSignalActive = true) ∧
      (¬i.linkAssuranceSignalPressed →
       o.linkAssuranceSignalActive = false) ∧
      (o.linkAssuranceSignalActive = true →
       i.periodicButtonPressed = true))

example : Spec.pre { mode := "2", linkAssuranceSignalPressed := false, periodicButtonPressed := true } ∧
          Spec.post { mode := "2", linkAssuranceSignalPressed := false, periodicButtonPressed := true }
                    { linkAssuranceSignalActive := false } := by
  unfold Spec; decide
