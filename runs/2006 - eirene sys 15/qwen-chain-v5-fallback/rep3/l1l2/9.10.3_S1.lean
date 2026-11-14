import ContractForge
open ContractForge

-- 9.10.3/S1: Where access to public networks is allowed, this shall be performed by using an Access Code (AC), defined in table 9-13, followed by the international or national number of the called subscriber as defined in [ITU-T 164].

-- L0 spec

structure AccessCode where
  value : Nat
  deriving DecidableEq, Repr

structure Input where
  accessCode : Option AccessCode
  internationalNumber : String
  nationalNumber : String
  deriving DecidableEq, Repr

structure Output where
  isValid : Bool
  internationalNumber : String
  nationalNumber : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.accessCode = some { value := 123 } ∨ i.accessCode = some { value := 456 }
  post := fun i o =>
    o.isValid = true ↔
    (i.accessCode = some { value := 123 } → i.internationalNumber ≠ "" ∧ i.nationalNumber = "")
    ∧
    (i.accessCode = some { value := 456 } → i.internationalNumber = "" ∧ i.nationalNumber ≠ "")
    ∧
    (i.accessCode = none → i.internationalNumber ≠ "" ∧ i.nationalNumber ≠ "")

example : Spec.pre { accessCode := some { value := 123 }, internationalNumber := "1234567890", nationalNumber := "" } ∧
          Spec.post { accessCode := some { value := 123 }, internationalNumber := "1234567890", nationalNumber := "" }
                    { isValid := true, internationalNumber := "1234567890", nationalNumber := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { isValid := decide ((x.accessCode = some { value := 123 } → x.internationalNumber ≠ "" ∧ x.nationalNumber = "")
    ∧
    (x.accessCode = some { value := 456 } → x.internationalNumber = "" ∧ x.nationalNumber ≠ "")
    ∧
    (x.accessCode = none → x.internationalNumber ≠ "" ∧ x.nationalNumber ≠ "")),
    internationalNumber := x.internationalNumber,
    nationalNumber := x.nationalNumber }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
