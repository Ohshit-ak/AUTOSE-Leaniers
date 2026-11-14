import ContractForge
open ContractForge

-- 4.1.5.1b: It shall be possible for the trackside to ask a driver for confirmation about the occupancy of the track ahead before sending a Full Supervision movement authority.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  track_occupancy : String
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.track_occupancy ≠ ""
  post := fun i o => o.confirmed = true ↔
    (i.track_occupancy = "occupied" → o.confirmed = false) ∧
    (i.track_occupancy = "clear" → o.confirmed = true)

example : Spec.pre { track_occupancy := "a" } ∧ Spec.post { track_occupancy := "a" } { confirmed := true } := by
  unfold Spec; decide
