import ContractForge
open ContractForge

-- 3.2.1.1/S2: The TCS shall present to the operator the estimated time of arrival and fuel status at each programmed waypoint of the proposed mission plan. [SSS088] At every waypoint and every 5 minutes, the TCS shall compute the AV's flight range based on remaining fuel. [SSS076] The TCS shall analyze the flight route plan selected for uplink to determine that the flight constraints of the AV and the limitation of the data link are not violated prior to transmission of the flight route plan to the AV. [SSS089] The algorithmic accuracy of all flight planning calculations shall not deviate by more than 10% when compared with a mission flown by a validated 6 degree-of-freedom air vehicle simulator. [SSS090] The flight route plan, as a minimum, shall provide the necessary AV commands to autonomously execute a programmed flight and return to a designated recovery area. [SSS091] The TCS shall provide the operator with an interactive graphics and map based flight route planning capability. [SSS092] The TCS shall provide the capability to create waypoints that define the desired flight path, define AV Altitude and Airspeed associated with the waypoint. [SSS093]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  estimatedTimeOfArrival : List Nat
  fuelStatus : List Nat
  flightRange : Nat
  flightConstraintsViolated : Bool
  algorithmAccuracy : Nat
  commands : List Nat
  recoveryArea : Nat
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.elapsedMicros ≤ 300000000
  post := fun i o =>
    o.estimatedTimeOfArrival.length = i.elapsedMicros / 5 ∧
    o.fuelStatus.length = i.elapsedMicros / 5 ∧
    o.flightRange ≤ 1000000000 ∧
    ¬o.flightConstraintsViolated ∧
    o.algorithmAccuracy ≤ 10 * (1000000000 / 10) ∧
    o.commands.length = 1000000000 / 10 ∧
    o.recoveryArea = 1000000000 / 10 ∧
    o.elapsedMicros ≤ 300000000

example : Spec.pre { elapsedMicros := 299999999 } ∧
          Spec.post { elapsedMicros := 299999999,
                      estimatedTimeOfArrival := [1, 2, 3, 4, 5],
                      fuelStatus := [10, 20, 30, 40, 50],
                      flightRange := 500000000,
                      flightConstraintsViolated := false,
                      algorithmAccuracy := 100000000,
                      commands := [100000000, 200000000, 300000000, 400000000, 500000000],
                      recoveryArea := 100000000 } := by
  unfold Spec; decide
