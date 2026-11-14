import ContractForge
open ContractForge

-- 4.1.2.11: Stored train data shall be offered to the driver to be confirmed when Data Entry starts.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { trains := x.trains,
    driver := x.driver,
    confirmed := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
