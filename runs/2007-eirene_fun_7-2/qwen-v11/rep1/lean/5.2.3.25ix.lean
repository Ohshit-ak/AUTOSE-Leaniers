import ContractForge
open ContractForge

-- 5.2.3.25ix: 5.2.3.25ix Automatic network selection is not suitable for use in areas where there is a risk that the Cab radio will change to a foreign network unpredictably. (I)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  cabNetwork : String
  availableNetworks : List String
  riskLevel : Nat
  deriving DecidableEq, Repr

structure Output where
  selectedNetwork : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.riskLevel > 5
  post := fun i o => (o.selectedNetwork = i.cabNetwork ↔
    i.availableNetworks.contains i.cabNetwork) ∧
    (o.selectedNetwork ≠ i.cabNetwork ↔
    i.availableNetworks.any (fun n => n ≠ i.cabNetwork ∧ n ≠ "foreign") ∧ i.riskLevel > 5)

example : Spec.pre { cabNetwork := "", availableNetworks := ["net1", "net2"], riskLevel := 6 } ∧ Spec.post { cabNetwork := "", availableNetworks := ["net1", "net2"], riskLevel := 6 } { selectedNetwork := "net1" } := by
  unfold Spec; decide
