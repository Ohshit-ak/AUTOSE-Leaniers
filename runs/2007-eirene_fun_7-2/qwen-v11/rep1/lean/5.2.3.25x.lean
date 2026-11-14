import ContractForge
open ContractForge

-- 5.2.3.25x: 5.2.3.25x If directed network selection and/or automatic network selection are implemented, the driver shall be informed by means of an audible and visual indication of the new network identity whenever a network change takes place without user intervention. (M) Register and deregister train number
-- compiles: True · rejects_bad_example: True · checked: True

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
