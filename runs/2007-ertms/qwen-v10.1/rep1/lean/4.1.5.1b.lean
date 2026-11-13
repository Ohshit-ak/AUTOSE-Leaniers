import ContractForge
open ContractForge

-- 4.1.5.1b: It shall be possible for the trackside to ask a driver for confirmation about the occupancy of the track ahead before sending a Full Supervision movement authority.
-- compiles: True · rejects_bad_example: True · checked: True

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
