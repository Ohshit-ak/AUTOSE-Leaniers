import ContractForge
open ContractForge

-- 4.1.2.11: Stored train data shall be offered to the driver to be confirmed when Data Entry starts.

-- L0 spec

structure Train where
  id   : Nat
  model: String
  deriving DecidableEq, Repr

structure DriverData where
  id   : Nat
  name : String
  deriving DecidableEq, Repr

structure Input where
  trains     : List Train
  drivers    : List DriverData
  selectedTrain : Option Train
  deriving DecidableEq, Repr

structure Output where
  trains     : List Train
  drivers    : List DriverData
  selectedTrain : Option Train
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selectedTrain.isSome
  post := fun i o => o.confirmed = true ∧
                     o.selectedTrain = i.selectedTrain ∧
                     o.trains = i.trains ∧
                     o.drivers = i.drivers

example : Spec.pre { trains := [{ id := 1, model := "Engine" }],
                     drivers := [{ id := 1, name := "John" }],
                     selectedTrain := some { id := 1, model := "Engine" } } ∧
          Spec.post { trains := [{ id := 1, model := "Engine" }],
                      drivers := [{ id := 1, name := "John" }],
                      selectedTrain := some { id := 1, model := "Engine" } }
                    { trains := [{ id := 1, model := "Engine" }],
                      drivers := [{ id := 1, name := "John" }],
                      selectedTrain := some { id := 1, model := "Engine" },
                      confirmed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { trains := x.trains,
    drivers := x.drivers,
    selectedTrain := x.selectedTrain,
    confirmed := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
