import ContractForge
open ContractForge

-- 9.5.1: 9.5.1 Authorised users within the EIRENE network shall be able to receive calls from calling parties outside the EIRENE network. (M)

-- L0 spec

structure Input where
  callerNumber : String
  callingParty : String
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.callerNumber ≠ "" ∧ i.callingParty ≠ ""
  post := fun i o => (o.accepted = true ↔
    i.callerNumber.toList.all Char.isDigit = true ∧
    i.callingParty.toList.all Char.isDigit = true)

example : Spec.pre { callerNumber := "123456789", callingParty := "987654321" } ∧
          Spec.post { callerNumber := "123456789", callingParty := "987654321" }
                    { accepted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { accepted := decide (x.callerNumber.toList.all Char.isDigit = true ∧
    x.callingParty.toList.all Char.isDigit = true) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
