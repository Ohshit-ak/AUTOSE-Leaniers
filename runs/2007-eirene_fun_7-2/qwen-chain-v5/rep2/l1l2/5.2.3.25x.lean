import ContractForge
open ContractForge

-- 5.2.3.25x: 5.2.3.25x If directed network selection and/or automatic network selection are implemented, the driver shall be informed by means of an audible and visual indication of the new network identity whenever a network change takes place without user intervention. (M) Register and deregister train number

-- L0 spec

structure Input where
  trainNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  trainNumber : String
  indication  : Bool
  deriving DecidableEq, Repr

-- IMPL: Network change indication

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumbers.length > 0
  post := fun i o => (o.indication = true ↔
    ∃ train ∈ i.trainNumbers, train ≠ "" ∧
    (i.trainNumbers.count train = 1 ∧
     ∃ newTrain ∈ i.trainNumbers, newTrain ≠ train ∧
     i.trainNumbers.count newTrain = 1))

example : Spec.pre { trainNumbers := ["12345", "67890"] } ∧
          Spec.post { trainNumbers := ["12345", "67890"] }
                    { trainNumber := "67890", indication := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { trainNumber := "",
    indication := decide (∃ train ∈ x.trainNumbers, train ≠ "" ∧
    (x.trainNumbers.count train = 1 ∧
     ∃ newTrain ∈ x.trainNumbers, newTrain ≠ train ∧
     x.trainNumbers.count newTrain = 1)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
