import ContractForge
open ContractForge

-- 4.1.2.14b: The change of driver identification during a journey or a Train Running Number shall be possible

-- L0 spec

structure Driver where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Journey where
  trainNumber : Nat
  drivers : List Driver
  currentDriverId : Nat
  deriving DecidableEq, Repr

structure Input where
  trainNumber : Nat
  currentDriverId : Nat
  newDriverId : Nat
  drivers : List Driver
  deriving DecidableEq, Repr

structure Output where
  trainNumber : Nat
  currentDriverId : Nat
  newDriverId : Nat
  drivers : List Driver
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ 0 ∧ 0 < i.currentDriverId ∧ 0 < i.newDriverId
  post := fun i o => o.trainNumber = i.trainNumber ∧
                     o.currentDriverId = i.newDriverId ∧
                     o.newDriverId = i.newDriverId ∧
                     (∃ d ∈ o.drivers, d.id = i.newDriverId) ∧
                     (o.drivers.Nodup)

example : Spec.pre { trainNumber := 1234, currentDriverId := 5, newDriverId := 6,
                     drivers := [{ id := 5, name := "Driver 5" }, { id := 6, name := "Driver 6" }] }
          ∧ Spec.post { trainNumber := 1234, currentDriverId := 5, newDriverId := 6,
                        drivers := [{ id := 5, name := "Driver 5" }, { id := 6, name := "Driver 6" }] }
                      { trainNumber := 1234, currentDriverId := 6, newDriverId := 6,
                        drivers := [{ id := 5, name := "Driver 5" }, { id := 6, name := "Driver 6" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { trainNumber := x.trainNumber,
    currentDriverId := x.newDriverId,
    newDriverId := x.newDriverId,
    drivers := x.drivers.filter (fun d => d.id = x.newDriverId) }
