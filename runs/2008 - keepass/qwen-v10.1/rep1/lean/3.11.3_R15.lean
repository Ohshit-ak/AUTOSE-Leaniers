import ContractForge
open ContractForge

-- 3.11.3/R15: ìWhen the password field is changed the repeat password field must be Changed and be identical with password field
-- compiles: True · rejects_bad_example: True · checked: True

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
