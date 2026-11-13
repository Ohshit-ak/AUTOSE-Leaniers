import ContractForge
open ContractForge

-- 3.11.3/R15: ìWhen the password field is changed the repeat password field must be Changed and be identical with password field

-- L0 spec

structure Input where
  password  : String
  repeatPassword : String
  deriving DecidableEq, Repr

structure Output where
  password  : String
  repeatPassword : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.repeatPassword = i.repeatPassword ∧
                     o.repeatPassword = o.password

example : Spec.pre { password := "newpass", repeatPassword := "newpass" } ∧
          Spec.post { password := "newpass", repeatPassword := "newpass" }
                    { password := "newpass", repeatPassword := "newpass" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  repeatPassword : String
  isCorrect      : Bool
  deriving DecidableEq, Repr

def ValidateRepeatPasswordContract : Contract Input Mid where
  pre  := fun i => True
  post := fun i m => m.repeatPassword = i.repeatPassword ∧ m.isCorrect = (i.repeatPassword = i.password)

def FinalizeOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.repeatPassword = m.repeatPassword ∧ o.password = m.repeatPassword ∧ m.isCorrect = (m.repeatPassword = o.password)

theorem po1 : Contract.Compatible ValidateRepeatPasswordContract FinalizeOutputContract := by
  discharge_po1 [ValidateRepeatPasswordContract, FinalizeOutputContract, Spec]

theorem po2 : Contract.Refines (ValidateRepeatPasswordContract.seq FinalizeOutputContract) Spec := by
  discharge_po2 [ValidateRepeatPasswordContract, FinalizeOutputContract, Spec]

-- L2 ValidateRepeatPasswordContract (success=True)

def ValidateRepeatPasswordContractImpl (x : Input) : Mid :=
  { repeatPassword := x.repeatPassword, isCorrect := (x.repeatPassword = x.password) }

theorem ValidateRepeatPasswordContractImpl_ok : ValidateRepeatPasswordContract.Satisfies ValidateRepeatPasswordContractImpl := by
  discharge_po3 [ValidateRepeatPasswordContract, ValidateRepeatPasswordContractImpl]

-- L2 FinalizeOutputContract (success=False)

def FinalizeOutputContractImpl (x : Mid) : Output :=
  { password := x.repeatPassword, repeatPassword := x.repeatPassword }
