import ContractForge
open ContractForge

-- 4.9.9.2: The following train data shall be sent from the on board to the trackside: Train running number STM ready for use train gauge Max. axle load status of air tight system type of el. power accepted international train category max. train speed train length

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { runningNumber := x.runningNumber,
    gauge := x.gauge,
    maxAxleLoad := x.maxAxleLoad,
    airTight := x.airTight,
    elPowerType := x.elPowerType,
    intCategory := x.intCategory,
    maxSpeed := x.maxSpeed,
    length := x.length }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
