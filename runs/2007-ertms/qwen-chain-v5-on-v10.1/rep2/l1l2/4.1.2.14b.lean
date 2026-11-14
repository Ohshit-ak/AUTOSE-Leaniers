import ContractForge
open ContractForge

-- 4.1.2.14b: The change of driver identification during a journey or a Train Running Number shall be possible

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { train := x.train,
    success := 
      ∃ d ∈ x.train.drivers, d.id = x.newDriverId ∧
      (x.train.currentDriverIndex = x.train.currentDriverIndex + 1 ∨
       x.train.currentDriverIndex = 0 ∧ x.train.drivers.length = 1) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
