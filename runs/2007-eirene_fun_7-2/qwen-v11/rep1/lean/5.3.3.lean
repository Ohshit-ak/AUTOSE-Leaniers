import ContractForge
open ContractForge

-- 5.3.3: 5.3.3 Measures should be taken to reduce the risk of theft of radio equipment. Examples of such measures include physical protection, alarms and access control measures. (I)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  radioEquipment : Nat
  securityMeasures : Nat
  alarms : Nat
  accessControl : Nat
  deriving DecidableEq, Repr

structure Output where
  riskReduced : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.radioEquipment
  post := fun i o => o.riskReduced = true ↔
    (i.securityMeasures ≥ 5 ∨
     (i.alarms ≥ 1 ∧ i.accessControl ≥ 1))

example : Spec.pre { radioEquipment := 10, securityMeasures := 8, alarms := 2, accessControl := 3 } ∧
          Spec.post { radioEquipment := 10, securityMeasures := 8, alarms := 2, accessControl := 3 }
                    { riskReduced := true } := by
  unfold Spec; decide
