import ContractForge
open ContractForge

-- 5.5.9/S1: The driver shall be able to initiate a call by selecting a name/number from stored number information in the radio.

-- L0 spec

structure StoredNumber where
  name  : String
  number : String
  deriving DecidableEq, Repr

structure Input where
  selectedNumber : Option StoredNumber
  callsInProgress : Nat
  deriving DecidableEq, Repr

structure Output where
  callInitiated : Bool
  callsInProgress : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selectedNumber.isSome
  post := fun i o => o.callInitiated = true ∧
                     o.callsInProgress = i.callsInProgress + 1

example : Spec.pre { selectedNumber := some { name := "John", number := "1234567890" },
                     callsInProgress := 0 } ∧
          Spec.post { selectedNumber := some { name := "John", number := "1234567890" },
                      callsInProgress := 0 }
                    { callInitiated := true, callsInProgress := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { callInitiated := true, callsInProgress := x.callsInProgress + 1 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
