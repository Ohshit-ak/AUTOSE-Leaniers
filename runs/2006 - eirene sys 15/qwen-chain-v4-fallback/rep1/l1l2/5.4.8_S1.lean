import ContractForge
open ContractForge

-- 5.4.8/S1: Upon activation of the deregistration function, a USSD message (see section 11) shall be sent by the Cab radio.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sent := true, message := "USSD deregistration message" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
