import ContractForge
open ContractForge

-- 5.2.2ii: 5.2.2ii Picking up the handset shall transfer the communication to the handset and reduce the loudspeaker volume to its minimum level. (M)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { communicationTransferred := true, loudspeakerVolumeReduced := x.loudspeakerVolume = 0 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
