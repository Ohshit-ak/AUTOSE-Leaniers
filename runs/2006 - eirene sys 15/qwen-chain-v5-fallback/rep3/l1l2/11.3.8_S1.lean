import ContractForge
open ContractForge

-- 11.3.8/S1: The network operator shall implement the required functionality to validate the information exchanged between the mobile and network on registration and deregistration.

-- L0 spec

structure Input where
  mobileNumber : String
  deriving DecidableEq, Repr

structure Output where
  isValid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileNumber ≠ ""
  post := fun i o => o.isValid = true ↔
    (i.mobileNumber.toList.all Char.isDigit = true) ∧
    (i.mobileNumber.length = 10)

example : Spec.pre { mobileNumber := "1234567890" } ∧
          Spec.post { mobileNumber := "1234567890" }
                    { isValid := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { isValid := decide ((x.mobileNumber.toList.all Char.isDigit = true) ∧
    (x.mobileNumber.length = 10)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
