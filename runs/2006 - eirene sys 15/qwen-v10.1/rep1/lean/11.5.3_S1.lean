import ContractForge
open ContractForge

-- 11.5.3/S1: If the calling party functional number is not available or if the calling party is not registered then the CLI of the calling party shall be displayed on the receiving mobile's display.
-- compiles: True · rejects_bad_example: True · checked: True

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
