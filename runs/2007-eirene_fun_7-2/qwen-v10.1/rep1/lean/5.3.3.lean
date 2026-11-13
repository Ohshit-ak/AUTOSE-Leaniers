import ContractForge
open ContractForge

-- 5.3.3: 5.3.3 Measures should be taken to reduce the risk of theft of radio equipment. Examples of such measures include physical protection, alarms and access control measures. (I)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  radioEquipment : Nat
  securityMeasures : Nat
  alarms : Nat
  accessControls : Nat
  deriving DecidableEq, Repr

structure Output where
  riskReduced : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.radioEquipment > 5
  post := fun i o => o.riskReduced = true ↔
    (i.securityMeasures > 0 ∧
     (i.alarms > 0 ∨
      i.accessControls > 0))

example : Spec.pre { radioEquipment := 6, securityMeasures := 1, alarms := 0, accessControls := 1 } ∧
          Spec.post { radioEquipment := 6, securityMeasures := 1, alarms := 0, accessControls := 1 }
                    { riskReduced := true } := by
  unfold Spec; decide
