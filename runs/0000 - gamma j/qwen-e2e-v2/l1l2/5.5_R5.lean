import ContractForge
open ContractForge

-- 5.5/R5: The system shall validate email address existence.

-- L0 spec

structure Input where
  email : String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ ""
  post := fun i o => o.exists_ = true ↔ i.email.toList.all Char.isAlphanum = true ∧
                     i.email.contains '@' ∧ i.email.contains '.' ∧
                     i.email.length ≥ 6

example : Spec.pre { email := "test@example.com" } ∧ Spec.post { email := "test@example.com" } { exists_ := false } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  email : String
  deriving DecidableEq, Repr

def ValidateEmailContract : Contract Input Mid where
  pre  := fun i => i.email ≠ ""
  post := fun i m => m.email = i.email ∧
                    m.email.toList.all Char.isAlphanum = true ∧
                    m.email.contains '@' ∧
                    m.email.contains '.' ∧
                    m.email.length ≥ 6

def CheckEmailContract : Contract Mid Output where
  pre  := fun m => m.email ≠ ""
  post := fun m o => o.exists_ = true

theorem po1 : Contract.Compatible ValidateEmailContract CheckEmailContract := by
  discharge_po [CheckEmailContract, Spec, ValidateEmailContract]

theorem po2 : Contract.Refines (ValidateEmailContract.seq CheckEmailContract) Spec := by
  discharge_po [CheckEmailContract, Spec, ValidateEmailContract]

-- L2 ValidateEmailContract (success=False)

def ValidateEmailContractImpl (i : Input) : Mid := { email := i.email }

theorem ValidateEmailContractImpl_ok : ValidateEmailContract.Satisfies ValidateEmailContractImpl := by
  unfold Contract.Satisfies
  intro i
  simp_all
  split
  { assumption }
  { assumption }

-- L2 CheckEmailContract (success=True)

def CheckEmailContractImpl (m : Mid) : Output := { exists_ := true }

theorem CheckEmailContractImpl_ok : CheckEmailContract.Satisfies CheckEmailContractImpl := by
  discharge_po [CheckEmailContract, CheckEmailContractImpl, Spec, ValidateEmailContract]