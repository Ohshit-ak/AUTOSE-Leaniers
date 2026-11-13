import ContractForge
open ContractForge

-- 4.1.2.11: Stored train data shall be offered to the driver to be confirmed when Data Entry starts.
-- compiles: True · rejects_bad_example: True · checked: True

structure Train where
  id : Nat
  destination : String
  schedule : String
  deriving DecidableEq, Repr

structure Driver where
  name : String
  deriving DecidableEq, Repr

structure Input where
  trains : List Train
  driver : Driver
  deriving DecidableEq, Repr

structure Output where
  trains : List Train
  driver : Driver
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trains.Nodup
  post := fun i o => o.confirmed = true ∧
                     (o.trains = i.trains) ∧
                     (o.driver = i.driver)

example : Spec.pre { trains := [{ id := 1, destination := "New York", schedule := "10:00" }],
                     driver := { name := "John Doe" } } ∧
          Spec.post { trains := [{ id := 1, destination := "New York", schedule := "10:00" }],
                      driver := { name := "John Doe" } }
                    { confirmed := true, trains := [{ id := 1, destination := "New York", schedule := "10:00" }],
                      driver := { name := "John Doe" } } := by
  unfold Spec; decide
