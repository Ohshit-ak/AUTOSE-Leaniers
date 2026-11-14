import ContractForge
open ContractForge

-- 5.2.3.25ix: 5.2.3.25ix Automatic network selection is not suitable for use in areas where there is a risk that the Cab radio will change to a foreign network unpredictably. (I)

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { selectedNetwork := if x.availableNetworks.contains x.cabNetwork then x.cabNetwork else
      if x.availableNetworks.any (fun n => n ≠ x.cabNetwork ∧ n ≠ "foreign") ∧ x.riskLevel > 5 then "foreign" else "" }
