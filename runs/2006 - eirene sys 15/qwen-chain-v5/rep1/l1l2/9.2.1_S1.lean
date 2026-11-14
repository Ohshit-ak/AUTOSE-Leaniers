import ContractForge
open ContractForge

-- 9.2.1/S1: Within each GSM-R network, each Train Number shall be unique for the period of the journey.

-- L0 spec

structure TrainNumber where
  value : String
  deriving DecidableEq, Repr

structure Input where
  trainNumbers : List TrainNumber
  deriving DecidableEq, Repr

structure Output where
  trainNumbers : List TrainNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.trainNumbers.Nodup ∧
                     (∀ tn ∈ i.trainNumbers, tn ∈ o.trainNumbers)

example : Spec.pre { trainNumbers := [{ value := "T123" }, { value := "T456" }] } ∧
          Spec.post { trainNumbers := [{ value := "T123" }, { value := "T456" }] }
                    { trainNumbers := [{ value := "T123" }, { value := "T456" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { trainNumbers := x.trainNumbers.nodup }
