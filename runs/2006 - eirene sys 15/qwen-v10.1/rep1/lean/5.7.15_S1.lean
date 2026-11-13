import ContractForge
open ContractForge

-- 5.7.15/S1: The Cab radio equipment shall be capable of withstanding the following changes to the main and backup power supplies without interrupting normal operation: (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mainPower  : String
  backupPower: String
  deriving DecidableEq, Repr

structure Output where
  normalOperation : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mainPower = "M" ∧ i.backupPower = "M"
  post := fun i o => o.normalOperation = true

example : Spec.pre { mainPower := "M", backupPower := "M" } ∧
          Spec.post { mainPower := "M", backupPower := "M" }
                    { normalOperation := true } := by
  unfold Spec; decide
