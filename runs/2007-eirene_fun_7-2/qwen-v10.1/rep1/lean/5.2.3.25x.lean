import ContractForge
open ContractForge

-- 5.2.3.25x: 5.2.3.25x If directed network selection and/or automatic network selection are implemented, the driver shall be informed by means of an audible and visual indication of the new network identity whenever a network change takes place without user intervention. (M) Register and deregister train number
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  trainNumber : String
  networkIdentity : String
  indication : Bool
  deriving DecidableEq, Repr

structure Output where
  trainNumber : String
  networkIdentity : String
  indication : Bool
  deriving DecidableEq, Repr

-- IMPL: Network selection and change indication

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ "" ∧ i.networkIdentity ≠ "" ∧ i.indication = true
  post := fun i o => (o.indication = true ↔
    (i.networkIdentity ≠ o.networkIdentity ∧
     (i.networkIdentity = "newNetwork" ∨ i.networkIdentity = "anotherNetwork")))

example : Spec.pre { trainNumber := "12345", networkIdentity := "oldNetwork", indication := true } ∧ Spec.post { trainNumber := "12345", networkIdentity := "oldNetwork", indication := true } { trainNumber := "12345", networkIdentity := "newNetwork", indication := false } := by
  unfold Spec; decide
