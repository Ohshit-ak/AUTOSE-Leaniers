import ContractForge
open ContractForge

-- 9.5.1: 9.5.1 Authorised users within the EIRENE network shall be able to receive calls from calling parties outside the EIRENE network. (M)

-- L0 spec

structure Input where
  callerNumber : String
  calledNumber : String
  callerNetwork : String
  calledNetwork : String
  callerAuthorised : Bool
  deriving DecidableEq, Repr

structure Output where
  callAccepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callerNetwork ≠ "" ∧ i.calledNetwork ≠ "" ∧ i.callerAuthorised
  post := fun i o => (o.callAccepted = true ↔
    i.callerNetwork ≠ i.calledNetwork ∧ i.callerAuthorised)

example : Spec.pre { callerNumber := "1234567890", calledNumber := "0987654321",
                     callerNetwork := "external", calledNetwork := "EIRENE",
                     callerAuthorised := true } ∧
          Spec.post { callerNumber := "1234567890", calledNumber := "0987654321",
                      callerNetwork := "external", calledNetwork := "EIRENE",
                      callerAuthorised := true }
                    { callAccepted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { callAccepted := decide (x.callerNetwork ≠ x.calledNetwork ∧ x.callerAuthorised) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
