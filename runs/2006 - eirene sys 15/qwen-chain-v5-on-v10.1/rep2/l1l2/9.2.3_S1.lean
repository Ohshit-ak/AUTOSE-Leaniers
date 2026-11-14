import ContractForge
open ContractForge

-- 9.2.3/S1: All Train Function Numbers and their associated MSISDN numbers shall be stored in the same routing database, which is the database of the GSM-R network in which the train is currently operating.

-- L0 spec

structure TrainFunctionNumber where
  number : Nat
  msisdn : String
  deriving DecidableEq, Repr

structure RoutingDatabase where
  trainFunctionNumbers : List TrainFunctionNumber
  deriving DecidableEq, Repr

structure Input where
  trainFunctionNumbers : List TrainFunctionNumber
  deriving DecidableEq, Repr

structure Output where
  trainFunctionNumbers : List TrainFunctionNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainFunctionNumbers.Nodup
  post := fun i o => o.trainFunctionNumbers = i.trainFunctionNumbers ∧
                     ∀ fn ∈ i.trainFunctionNumbers, fn.msisdn ≠ ""

example : Spec.pre { trainFunctionNumbers := [{ number := 1, msisdn := "1234567890" },
                                               { number := 2, msisdn := "0987654321" }] } ∧
          Spec.post { trainFunctionNumbers := [{ number := 1, msisdn := "1234567890" },
                                                { number := 2, msisdn := "0987654321" }] }
                    { trainFunctionNumbers := [{ number := 1, msisdn := "1234567890" },
                                               { number := 2, msisdn := "0987654321" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { trainFunctionNumbers := x.trainFunctionNumbers.filter (fun fn => fn.msisdn ≠ "")
  }
