import ContractForge
open ContractForge

-- 11.5.4/S1: The user-to-user information element in the SETUP, ALERT or CONNECT messages, as defined in [EN 301 515, Index [16]], shall be used to transfer the functional number of the calling party to the called party.

-- L0 spec

structure Input where
  callingPartyNumber : String
  deriving DecidableEq, Repr

structure Output where
  calledPartyNumber : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callingPartyNumber ≠ ""
  post := fun i o => o.calledPartyNumber = i.callingPartyNumber ∧
                     (o.calledPartyNumber ≠ i.callingPartyNumber →
                      o.calledPartyNumber = "0000000000")

example : Spec.pre { callingPartyNumber := "1234567890" } ∧
          Spec.post { callingPartyNumber := "1234567890" }
                    { calledPartyNumber := "1234567890" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { calledPartyNumber := x.callingPartyNumber }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
