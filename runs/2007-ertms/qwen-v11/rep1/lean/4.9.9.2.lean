import ContractForge
open ContractForge

-- 4.9.9.2: The following train data shall be sent from the on board to the trackside: Train running number STM ready for use train gauge Max. axle load status of air tight system type of el. power accepted international train category max. train speed train length
-- compiles: True · rejects_bad_example: None · checked: True

structure TrainData where
  runningNumber : String
  gauge         : Nat
  maxAxleLoad   : Nat
  airTight      : Bool
  elPowerType   : String
  intCategory   : String
  maxSpeed      : Nat
  length        : Nat
  deriving DecidableEq, Repr

structure Input where
  runningNumber : String
  gauge         : Nat
  maxAxleLoad   : Nat
  airTight      : Bool
  elPowerType   : String
  intCategory   : String
  maxSpeed      : Nat
  length        : Nat
  deriving DecidableEq, Repr

structure Output where
  runningNumber : String
  gauge         : Nat
  maxAxleLoad   : Nat
  airTight      : Bool
  elPowerType   : String
  intCategory   : String
  maxSpeed      : Nat
  length        : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.runningNumber = i.runningNumber ∧
                     o.gauge = i.gauge ∧
                     o.maxAxleLoad = i.maxAxleLoad ∧
                     o.airTight = i.airTight ∧
                     o.elPowerType = i.elPowerType ∧
                     o.intCategory = i.intCategory ∧
                     o.maxSpeed = i.maxSpeed ∧
                     o.length = i.length

example : Spec.pre { runningNumber := "12345", gauge := 1435, maxAxleLoad := 25000,
                     airTight := true, elPowerType := "AC", intCategory := "IC",
                     maxSpeed := 200, length := 200 } ∧
          Spec.post { runningNumber := "12345", gauge := 1435, maxAxleLoad := 25000,
                      airTight := true, elPowerType := "AC", intCategory := "IC",
                      maxSpeed := 200, length := 200 }
                    { runningNumber := "12345", gauge := 1435, maxAxleLoad := 25000,
                      airTight := true, elPowerType := "AC", intCategory := "IC",
                      maxSpeed := 200, length := 200 } := by
  unfold Spec; decide
