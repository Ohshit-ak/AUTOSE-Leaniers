import ContractForge
open ContractForge

-- 8.3.4/S1: Any group call controller who wishes to stop talking shall indicate his wish, for example by releasing the PTT button, whereupon the 3-digit DTMF sequence "#**" shall be transferred.

-- L0 spec

structure Input where
  pttReleased : Bool
  deriving DecidableEq, Repr

structure Output where
  muted : Bool
  dmfSequence : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.pttReleased
  post := fun i o => o.muted = true ∧
                     o.dmfSequence = "#**"

example : Spec.pre { pttReleased := true } ∧
          Spec.post { pttReleased := true }
                    { muted := true, dmfSequence := "#**" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { muted := true, dmfSequence := "#**" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
