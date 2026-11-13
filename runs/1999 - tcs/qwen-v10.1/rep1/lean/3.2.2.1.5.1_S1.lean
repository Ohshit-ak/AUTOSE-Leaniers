import ContractForge
open ContractForge

-- 3.2.2.1.5.1/S1: The TCS shall display the AV status, to include but not be limited to the AV location and flight and avionics system status. [SSS143] When the data link is interrupted, the TCS shall present the last known AV status values and the time at which the last values were reported. [SSS144] The TCS shall be capable of displaying fuel parameters to the operator to include as a minimum, remaining fuel, flow rate, and bingo fuel. [SSS145] Bingo fuel is the minimum amount of fuel necessary to return to the designated Recovery site with reserve fuel.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  avLocation : String
  flightStatus : String
  avionicsStatus : String
  remainingFuel : Nat
  flowRate : Nat
  bingoFuel : Nat
  dataLinkInterruptionTime : Option Nat
  deriving DecidableEq, Repr

structure Output where
  avStatus : String
  flightAndAvionicsStatus : String
  remainingFuel : Nat
  flowRate : Nat
  bingoFuel : Nat
  lastUpdateTime : Option Nat
  avionicsStatus : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o =>
    o.avStatus = i.avLocation ∧
    o.flightAndAvionicsStatus = i.flightStatus ++ " " ++ i.avionicsStatus ∧
    o.remainingFuel = i.remainingFuel ∧
    o.flowRate = i.flowRate ∧
    o.bingoFuel = i.bingoFuel ∧
    (o.lastUpdateTime = i.dataLinkInterruptionTime ↔
      i.dataLinkInterruptionTime.isSome ∧
      o.avStatus = i.avLocation ∧
      o.flightAndAvionicsStatus = i.flightStatus ++ " " ++ i.avionicsStatus)

example : Spec.pre { avLocation := "hangar", flightStatus := "ready", avionicsStatus := "ok",
                     remainingFuel := 1000, flowRate := 50, bingoFuel := 500,
                     dataLinkInterruptionTime := some 123456789 } ∧
          Spec.post { avLocation := "hangar", flightStatus := "ready", avionicsStatus := "ok",
                      remainingFuel := 1000, flowRate := 50, bingoFuel := 500,
                      dataLinkInterruptionTime := some 123456789 }
                    { avStatus := "hangar", flightAndAvionicsStatus := "ready ok",
                      remainingFuel := 1000, flowRate := 50, bingoFuel := 500,
                      lastUpdateTime := some 123456789, avionicsStatus := "ok" } := by
  unfold Spec; decide
