import ContractForge
open ContractForge

-- 7.2.2.9: 7.2.2.9 If the system is not able to connect the call, an audible and visual indication shall be provided to the user. (M) Send Railway emergency call
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  systemConnected : Bool
  deriving DecidableEq, Repr

structure Output where
  audibleIndication : Bool
  visualIndication  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.systemConnected = false
  post := fun i o => (o.audibleIndication = true ∧ o.visualIndication = true) ↔
                     i.systemConnected = false

example : Spec.pre { systemConnected := false } ∧
          Spec.post { systemConnected := false }
                    { audibleIndication := true, visualIndication := true } := by
  unfold Spec; decide
