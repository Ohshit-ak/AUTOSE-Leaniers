import ContractForge
open ContractForge

-- 5.2.2ii: 5.2.2ii Picking up the handset shall transfer the communication to the handset and reduce the loudspeaker volume to its minimum level. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  handsetPickedUp : Bool
  loudspeakerVolume : Nat
  deriving DecidableEq, Repr

structure Output where
  communicationTransferred : Bool
  loudspeakerVolumeReduced : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.handsetPickedUp = true
  post := fun i o =>
    o.communicationTransferred = true ∧
    o.loudspeakerVolumeReduced = true ∧
    o.loudspeakerVolumeReduced ↔ i.loudspeakerVolume = 0

example : Spec.pre { handsetPickedUp := true, loudspeakerVolume := 0 } ∧
          Spec.post { handsetPickedUp := true, loudspeakerVolume := 0 }
                    { communicationTransferred := true, loudspeakerVolumeReduced := true } := by
  unfold Spec; decide
