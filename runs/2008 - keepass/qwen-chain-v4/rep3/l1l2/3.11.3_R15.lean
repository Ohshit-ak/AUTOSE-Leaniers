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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  password  : String
  deriving DecidableEq, Repr

def CheckPasswordsContract : Contract Input Mid where
  pre  := fun i => True
  post := fun i m => m.password = i.repeatPassword ∧ m.password = i.password

def VerifyRepeatContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.repeatPassword = m.password ∧ o.password = m.password
