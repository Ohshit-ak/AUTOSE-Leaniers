import ContractForge
open ContractForge

-- 5.4.7/S1: Upon activation of the registration function, a USSD message (see section 11) shall be sent by the Cab radio.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { ussdSent := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
