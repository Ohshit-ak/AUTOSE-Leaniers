import ContractForge
open ContractForge

-- 4.1.2.11: Stored train data shall be offered to the driver to be confirmed when Data Entry starts.
-- compiles: True · rejects_bad_example: True · checked: True

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
