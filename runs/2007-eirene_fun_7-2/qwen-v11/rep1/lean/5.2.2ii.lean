import ContractForge
open ContractForge

-- 5.2.2ii: 5.2.2ii Picking up the handset shall transfer the communication to the handset and reduce the loudspeaker volume to its minimum level. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  handsetPickedUp : Bool
  loudspeakerVolume : Nat
  deriving DecidableEq, Repr

structure Output where
  communicationTransferred : Bool
  loudspeakerVolume : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.handsetPickedUp
  post := fun i o => o.communicationTransferred = i.handsetPickedUp ∧
                     (o.communicationTransferred = true → o.loudspeakerVolume = 0)

example : Spec.pre { handsetPickedUp := true, loudspeakerVolume := 5 } ∧
          Spec.post { handsetPickedUp := true, loudspeakerVolume := 5 }
                    { communicationTransferred := true, loudspeakerVolume := 0 } := by
  unfold Spec; decide
