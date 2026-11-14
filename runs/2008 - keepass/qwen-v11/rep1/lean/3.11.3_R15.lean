import ContractForge
open ContractForge

-- 3.11.3/R15: ìWhen the password field is changed the repeat password field must be Changed and be identical with password field
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  password  : String
  repeatPassword : String
  changeRepeatPassword : Bool
  deriving DecidableEq, Repr

structure Output where
  password  : String
  repeatPassword : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.password = i.password ∧
                     (if i.changeRepeatPassword then
                        o.repeatPassword = i.password
                      else
                        o.repeatPassword = i.repeatPassword)

example : Spec.pre { password := "newpass", repeatPassword := "newpass", changeRepeatPassword := true } ∧
          Spec.post { password := "newpass", repeatPassword := "newpass", changeRepeatPassword := true }
                    { password := "newpass", repeatPassword := "newpass" } := by
  unfold Spec; decide
