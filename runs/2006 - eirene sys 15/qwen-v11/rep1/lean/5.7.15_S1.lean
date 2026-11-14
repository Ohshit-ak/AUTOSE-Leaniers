import ContractForge
open ContractForge

-- 5.7.15/S1: The Cab radio equipment shall be capable of withstanding the following changes to the main and backup power supplies without interrupting normal operation: (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  mainPower  : Nat
  backupPower: Nat
  deriving DecidableEq, Repr

structure Output where
  normalOperation : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.mainPower ∧ 0 < i.backupPower
  post := fun i o => (o.normalOperation = true ↔
    (i.mainPower ≠ 0 ∧ i.backupPower ≠ 0)) ∧
    (o.normalOperation = false ↔
    (i.mainPower = 0 ∨ i.backupPower = 0))

example : Spec.pre { mainPower := 120, backupPower := 120 } ∧ Spec.post { mainPower := 120, backupPower := 120 } { normalOperation := true } := by
  unfold Spec; decide
