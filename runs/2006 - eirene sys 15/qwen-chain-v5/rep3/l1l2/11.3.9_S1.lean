import ContractForge
open ContractForge

-- 11.3.9/S1: The result of the registration procedure shall be sent back to the mobile.

-- L0 spec

structure Input where
  mobileNumber : String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileNumber ≠ ""
  post := fun i o => (o.success = true ↔
    i.mobileNumber.toList.all Char.isDigit = true) ∧
                     (o.success = false → o.message = "Invalid mobile number")

example : Spec.pre { mobileNumber := "1234567890" } ∧
          Spec.post { mobileNumber := "1234567890" }
                    { success := true, message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  isDigit : Bool
  deriving DecidableEq, Repr

def ValidateMobileNumberContract : Contract Input Mid where
  pre  := fun i => i.mobileNumber ≠ ""
  post := fun i m => m.isDigit = (i.mobileNumber.toList.all Char.isDigit)

def FormatOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.success = true ↔ m.isDigit) ∧
                     (o.success = false → o.message = "Invalid mobile number")

theorem po1 : Contract.Compatible ValidateMobileNumberContract FormatOutputContract := by
  discharge_po1 [ValidateMobileNumberContract, FormatOutputContract, Spec]

theorem po2 : Contract.Refines (ValidateMobileNumberContract.seq FormatOutputContract) Spec := by
  discharge_po2 [ValidateMobileNumberContract, FormatOutputContract, Spec]

-- L2 ValidateMobileNumberContract (success=True)

def ValidateMobileNumberContractImpl (x : Input) : Mid :=
  { isDigit := x.mobileNumber.toList.all Char.isDigit }

theorem ValidateMobileNumberContractImpl_ok : ValidateMobileNumberContract.Satisfies ValidateMobileNumberContractImpl := by
  discharge_po3 [ValidateMobileNumberContract, ValidateMobileNumberContractImpl]

-- L2 FormatOutputContract (success=True)

def FormatOutputContractImpl (x : Mid) : Output :=
  { success := decide (x.isDigit),
    message := if x.isDigit then "" else "Invalid mobile number" }

theorem FormatOutputContractImpl_ok : FormatOutputContract.Satisfies FormatOutputContractImpl := by
  discharge_po3 [FormatOutputContract, FormatOutputContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (FormatOutputContractImpl ∘ ValidateMobileNumberContractImpl) :=
  Contract.system_sound po1 po2 ValidateMobileNumberContractImpl_ok FormatOutputContractImpl_ok
