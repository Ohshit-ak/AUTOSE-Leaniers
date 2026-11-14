import ContractForge
open ContractForge

-- 3.2.2.1.5.1/S2: The TCS shall compute the estimated position of the AV during Loss of Link (LOL) based upon the last known AV position and anticipated flight path based on current flight mode (e.g. flight route plan mode, emergency flight route plan mode, maintain current heading mode). [SSS146] TCS shall display a LOL timer to the operator initiating a LOL onset. [SSS536]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  lastKnownPosition : Nat -- position in some unit, e.g. meters
  flightMode        : String -- current flight mode
  deriving DecidableEq, Repr

structure Output where
  estimatedPosition : Nat -- estimated position during LOL
  lolTimer          : Nat -- time until LOL onset in some unit, e.g. seconds
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.lastKnownPosition ≠ 0 ∧ i.flightMode ≠ ""
  post := fun i o => o.estimatedPosition = i.lastKnownPosition + (match i.flightMode with
    | "flight route plan mode" => 100 -- example speed in the mode
    | "emergency flight route plan mode" => 200 -- example speed in the mode
    | "maintain current heading mode" => 50 -- example speed in the mode
    | _ => 0) ∧
    o.lolTimer = 60 -- example time until LOL onset in seconds

example : Spec.pre { lastKnownPosition := 1000, flightMode := "flight route plan mode" } ∧
          Spec.post { lastKnownPosition := 1000, flightMode := "flight route plan mode" }
                    { estimatedPosition := 1100, lolTimer := 60 } := by
  unfold Spec; decide
