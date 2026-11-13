import ContractForge
open ContractForge

-- 3.2.1.1/S1: The Flight Route Plan, as a minimum, shall include AV flight path information, Loss of Link plan, AV VCR control tasking (if applicable to the selected AV), and data link control information. [SSS079] The TCS shall allow the operator to define the desired AV route in waypoint format [SSS551], and shall provide the capability to include up to 500 waypoints in each flight route plan. [SSS080] The TCS shall provide the capability to display mission waypoints and flight path graphically. [SSS081] The TCS shall provide the capability to enter waypoint data in alphanumeric format. [SSS082] The TCS flight route planner shall include, as a minimum, the following flight planning tools:
-- compiles: True · rejects_bad_example: True · checked: True

structure Waypoint where
  id    : Nat
  lat   : Nat
  lon   : Nat
  alt   : Nat
  label : String
  deriving DecidableEq, Repr

structure FlightRoutePlan where
  waypoints : List Waypoint
  lossOfLinkPlan : String
  vcrControlTasking : Option String
  dataLinkControlInfo : String
  deriving DecidableEq, Repr

structure Input where
  waypoints   : List Waypoint
  maxWaypoints : Nat := 500
  lossOfLinkPlan : String
  vcrControlTasking : Option String
  dataLinkControlInfo : String
  deriving DecidableEq, Repr

structure Output where
  flightRoutePlan : FlightRoutePlan
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.waypoints.length ≤ i.maxWaypoints
  post := fun i o =>
    o.flightRoutePlan.waypoints.length = i.waypoints.length ∧
    o.flightRoutePlan.lossOfLinkPlan = i.lossOfLinkPlan ∧
    o.flightRoutePlan.vcrControlTasking = i.vcrControlTasking ∧
    o.flightRoutePlan.dataLinkControlInfo = i.dataLinkControlInfo ∧
    (o.flightRoutePlan.waypoints = i.waypoints →
      o.flightRoutePlan.waypoints.all (fun wp => wp.lat ≠ 0 ∧ wp.lon ≠ 0 ∧ wp.alt ≠ 0) = true)

example : Spec.pre { waypoints := [{ id := 1, lat := 1234, lon := 5678, alt := 90, label := "wp1" }],
                     maxWaypoints := 500,
                     lossOfLinkPlan := "Plan1",
                     vcrControlTasking := some "Task1",
                     dataLinkControlInfo := "Info1" } ∧
          Spec.post { waypoints := [{ id := 1, lat := 1234, lon := 5678, alt := 90, label := "wp1" }],
                      maxWaypoints := 500,
                      lossOfLinkPlan := "Plan1",
                      vcrControlTasking := some "Task1",
                      dataLinkControlInfo := "Info1" }
                    { flightRoutePlan := { waypoints := [{ id := 1, lat := 1234, lon := 5678, alt := 90, label := "wp1" }],
                                           lossOfLinkPlan := "Plan1",
                                           vcrControlTasking := some "Task1",
                                           dataLinkControlInfo := "Info1" } } := by
  unfold Spec; decide
