import ContractForge
open ContractForge

-- 5.3.3: 5.3.3 Measures should be taken to reduce the risk of theft of radio equipment. Examples of such measures include physical protection, alarms and access control measures. (I)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { riskReduced := decide (x.securityMeasures > 0 ∧ (x.alarms > 0 ∨ x.accessControls > 0)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
