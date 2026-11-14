import ContractForge
open ContractForge

-- 5.2.2.55: 5.2.2.55 If the train moves out of the group or broadcast call area whilst the call is in progress, an audible and visual indication of the loss of call shall be provided to the driver. (M) Receive incoming Railway emergency call
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  trainMoved : Bool
  inCall     : Bool
  inGroupCallArea : Bool
  inBroadcastCallArea : Bool
  deriving DecidableEq, Repr

structure Output where
  audibleIndication : Bool
  visualIndication  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.inCall ∧ (i.inGroupCallArea ∨ i.inBroadcastCallArea)
  post := fun i o => (i.trainMoved = true →
    (o.audibleIndication = true ∧ o.visualIndication = true) ↔
    (i.inGroupCallArea = false ∧ i.inBroadcastCallArea = false))

example : Spec.pre { trainMoved := true, inCall := true, inGroupCallArea := true, inBroadcastCallArea := false } ∧ Spec.post { trainMoved := true, inCall := true, inGroupCallArea := true, inBroadcastCallArea := false } { audibleIndication := false, visualIndication := false } := by
  unfold Spec; decide
