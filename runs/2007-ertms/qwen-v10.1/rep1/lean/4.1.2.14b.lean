import ContractForge
open ContractForge

-- 4.1.2.14b: The change of driver identification during a journey or a Train Running Number shall be possible
-- compiles: True · rejects_bad_example: None · checked: True

structure Driver where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Train where
  runningNumber : Nat
  drivers : List Driver
  currentDriverIndex : Nat
  deriving DecidableEq, Repr

structure Input where
  train : Train
  newDriverId : Nat
  deriving DecidableEq, Repr

structure Output where
  train : Train
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.newDriverId ≠ 0
  post := fun i o => o.success ↔
    ∃ d ∈ i.train.drivers, d.id = i.newDriverId ∧
    (o.train.currentDriverIndex = i.train.currentDriverIndex + 1 ∨
     o.train.currentDriverIndex = 0 ∧ i.train.drivers.length = 1) ∧
    o.train.runningNumber = i.train.runningNumber ∧
    o.train.drivers = i.train.drivers

example : Spec.pre { train := { runningNumber := 1234, drivers := [{ id := 1, name := "Driver1" }, { id := 2, name := "Driver2" }], currentDriverIndex := 0 },
                     newDriverId := 2 } ∧
          Spec.post { train := { runningNumber := 1234, drivers := [{ id := 1, name := "Driver1" }, { id := 2, name := "Driver2" }], currentDriverIndex := 0 },
                      newDriverId := 2 }
                    { train := { runningNumber := 1234, drivers := [{ id := 1, name := "Driver1" }, { id := 2, name := "Driver2" }], currentDriverIndex := 1 },
                      success := true } := by
  unfold Spec; decide
