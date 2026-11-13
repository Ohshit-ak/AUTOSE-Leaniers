import ContractForge
open ContractForge

-- 7.2.2.12: 7.2.2.12 If the emergency call function is disabled, a visual indication and short audible indication shall be given when: the radio is switched on; (M) the emergency button is pushed (in this case nothing else will happen). (M) Receive incoming point to point voice call
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  emergencyCallEnabled : Bool
  emergencyButtonPushed : Bool
  deriving DecidableEq, Repr

structure Output where
  visualIndication : Bool
  audibleIndication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => ¬i.emergencyCallEnabled
  post := fun i o => (o.visualIndication = true ∧ o.audibleIndication = true) ↔
                     (i.emergencyButtonPushed = true ∧ i.emergencyCallEnabled = false)

example : Spec.pre { emergencyCallEnabled := false, emergencyButtonPushed := false } ∧ Spec.post { emergencyCallEnabled := false, emergencyButtonPushed := false } { visualIndication := true, audibleIndication := false } := by
  unfold Spec; decide
