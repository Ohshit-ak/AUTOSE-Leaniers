import ContractForge
open ContractForge

-- 9.10.3/S1: Where access to public networks is allowed, this shall be performed by using an Access Code (AC), defined in table 9-13, followed by the international or national number of the called subscriber as defined in [ITU-T 164].
-- compiles: True · rejects_bad_example: None · checked: True

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
