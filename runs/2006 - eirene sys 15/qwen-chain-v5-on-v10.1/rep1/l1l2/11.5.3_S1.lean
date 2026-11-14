import ContractForge
open ContractForge

-- 11.5.3/S1: If the calling party functional number is not available or if the calling party is not registered then the CLI of the calling party shall be displayed on the receiving mobile's display.

-- L0 spec

structure Input where
  callingPartyFunctionalNumber : Option String
  callingPartyIsRegistered      : Bool
  callingPartyCLI               : String
  deriving DecidableEq, Repr

structure Output where
  displayedCLI : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callingPartyFunctionalNumber = none ∨ ¬i.callingPartyIsRegistered
  post := fun i o => o.displayedCLI = i.callingPartyCLI

example : Spec.pre { callingPartyFunctionalNumber := none,
                     callingPartyIsRegistered := false,
                     callingPartyCLI := "1234567890" } ∧
          Spec.post { callingPartyFunctionalNumber := none,
                      callingPartyIsRegistered := false,
                      callingPartyCLI := "1234567890" }
                    { displayedCLI := "1234567890" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { displayedCLI := x.callingPartyCLI }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
