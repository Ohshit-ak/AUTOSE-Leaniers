import ContractForge
open ContractForge

-- 14.2.8: 14.2.8 Operational radios used for shunting shall be able to be switched between the following two operating modes by a maintenance function: (M) Mode 1: the member is required to continuously press the link assurance signal button in order to transmit the link assurance signal; Mode 2: the member is required to switch on the link assurance signal and then periodically press a button in order to transmit the link assurance signal (failure to do so shall result in the deactivation of the link assurance signal after a predefined period has elapsed).

-- L0 spec

structure Input where
  mode : String
  linkAssuranceSignalPressed : Bool
  periodicButtonPressed : Bool
  deriving DecidableEq, Repr

structure Output where
  linkAssuranceSignalActive : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mode ∈ ["M1", "M2"]
  post := fun i o =>
    (i.mode = "M1" ↔ o.linkAssuranceSignalActive = true) ∧
    (i.mode = "M2" ↔
      (i.linkAssuranceSignalPressed = true ∧
       i.periodicButtonPressed = true → o.linkAssuranceSignalActive = true) ∧
      (i.linkAssuranceSignalPressed = true ∧
       i.periodicButtonPressed = false → o.linkAssuranceSignalActive = false))

example : Spec.pre { mode := "M1", linkAssuranceSignalPressed := true, periodicButtonPressed := false } ∧ Spec.post { mode := "M1", linkAssuranceSignalPressed := true, periodicButtonPressed := false } { linkAssuranceSignalActive := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { linkAssuranceSignalActive := decide (x.mode = "M1") ∨
      (x.mode = "M2" ∧
       (x.linkAssuranceSignalPressed = true ∧ x.periodicButtonPressed = true → true) ∧
       (x.linkAssuranceSignalPressed = true ∧ x.periodicButtonPressed = false → false)) }
