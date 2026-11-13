import ContractForge
open ContractForge

-- 2.1.1/I9: The filed office will validate the claim form manually and through system,

-- L0 spec

structure ClaimForm where
  formNumber : String
  patientName : String
  amount : Nat
  deriving DecidableEq, Repr

structure Input where
  formNumber : String
  patientName : String
  amount : Nat
  isValid : Bool
  deriving DecidableEq, Repr

structure Output where
  isValid : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.formNumber ≠ "" ∧ i.patientName ≠ "" ∧ 0 < i.amount
  post := fun i o => (o.isValid = true ↔ i.isValid) ∧
                     (o.message = "Claim form is valid." ↔ o.isValid = true) ∧
                     (o.message = "Claim form is invalid." ↔ o.isValid = false)

example : Spec.pre { formNumber := "F12345", patientName := "John Doe", amount := 500, isValid := true } ∧
          Spec.post { formNumber := "F12345", patientName := "John Doe", amount := 500, isValid := true }
                    { isValid := true, message := "Claim form is valid." } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  isValid : Bool
  deriving DecidableEq, Repr

def ValidateFormContract : Contract Input Mid where
  pre  := fun i => i.formNumber ≠ "" ∧ i.patientName ≠ "" ∧ 0 < i.amount
  post := fun i m => m.isValid = i.isValid

def GenerateMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.message = "Claim form is valid." ↔ o.isValid = true) ∧
                     (o.message = "Claim form is invalid." ↔ o.isValid = false)
