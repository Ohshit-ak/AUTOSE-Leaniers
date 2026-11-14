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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { communicationTransferred := x.handsetPickedUp,
    loudspeakerVolume := if x.handsetPickedUp then 0 else x.loudspeakerVolume }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
