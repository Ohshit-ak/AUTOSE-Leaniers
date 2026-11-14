import ContractForge
open ContractForge

-- 3.2.1.1/S1: The Flight Route Plan, as a minimum, shall include AV flight path information, Loss of Link plan, AV VCR control tasking (if applicable to the selected AV), and data link control information. [SSS079] The TCS shall allow the operator to define the desired AV route in waypoint format [SSS551], and shall provide the capability to include up to 500 waypoints in each flight route plan. [SSS080] The TCS shall provide the capability to display mission waypoints and flight path graphically. [SSS081] The TCS shall provide the capability to enter waypoint data in alphanumeric format. [SSS082] The TCS flight route planner shall include, as a minimum, the following flight planning tools:
-- compiles: False · rejects_bad_example: None · checked: False

structure Waypoint where
  name   : String
  lat    : Nat  -- latitude in degrees
  lon    : Nat  -- longitude in degrees
  alt    : Nat  -- altitude in meters
  deriving DecidableEq, Repr

structure Input where
  waypoints : List Waypoint
  maxWaypoints : Nat := 500
  deriving DecidableEq, Repr

structure Output where
  flightPlan : List Waypoint
  display   : Bool
  entryMode : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.waypoints.Nodup ∧ i.waypoints.length ≤ i.maxWaypoints
  post := fun i o => o.flightPlan.length = i.waypoints.length ∧
                     o.display = true ∧
                     o.entryMode = true

example : Spec.pre { waypoints := [{ name := "WP1", lat := 40, lon := -74, alt := 100 },
                                    { name := "WP2", lat := 41, lon := -75, alt := 110 }],
                    maxWaypoints := 500 } ∧
          Spec.post { waypoints := [{ name := "WP1", lat := 40, lon := -74, alt := 100 },
                                     { name := "WP2", lat := 41, lon := -75, alt := 110 }],
                      maxWaypoints := 500 }
                    { flightPlan := [{ name := "WP1", lat := 40, lon := -74, alt := 100 },
                                     { name := "WP2", lat := 41, lon := -75, alt := 110 }],
                      display := true, entryMode := true } := by
  unfold Spec; decide
