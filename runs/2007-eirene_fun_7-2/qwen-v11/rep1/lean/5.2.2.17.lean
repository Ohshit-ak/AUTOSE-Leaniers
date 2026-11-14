import ContractForge
open ContractForge

-- 5.2.2.17: 5.2.2.17 If the system is not able to connect the call, an audible and visual indication shall be provided to the driver. (M) Send Railway emergency call
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  systemConnected : Bool
  emergencyCallSent : Bool
  deriving DecidableEq, Repr

structure Output where
  audibleIndication : Bool
  visualIndication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.systemConnected = false ∧ i.emergencyCallSent = true
  post := fun i o => (o.audibleIndication = true ∧ o.visualIndication = true) ↔
    i.systemConnected = false ∧ i.emergencyCallSent = true

example : Spec.pre { systemConnected := false, emergencyCallSent := true } ∧
          Spec.post { systemConnected := false, emergencyCallSent := true }
                    { audibleIndication := true, visualIndication := true } := by
  unfold Spec; decide
