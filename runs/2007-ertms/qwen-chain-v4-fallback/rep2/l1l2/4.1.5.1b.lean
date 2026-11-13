import ContractForge
open ContractForge

-- 4.1.5.1b: It shall be possible for the trackside to ask a driver for confirmation about the occupancy of the track ahead before sending a Full Supervision movement authority.

-- L0 spec

structure Input where
  track_occupancy : String
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  track_occupancy : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.track_occupancy ≠ ""
  post := fun i o => o.confirmed = true ↔
    (i.track_occupancy = "empty" → o.track_occupancy = "empty") ∧
    (i.track_occupancy = "occupied" → o.track_occupancy = "occupied")

example : Spec.pre { track_occupancy := "empty" } ∧
          Spec.post { track_occupancy := "empty" }
                    { confirmed := true, track_occupancy := "empty" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmed := true, track_occupancy := x.track_occupancy }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
