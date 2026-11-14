import ContractForge
open ContractForge

-- 5.2.3.25i: 5.2.3.25i Manual network selection is suitable for crossing international borders. (I) Directed network selection 5.2.3.25iv If directed network selection is implemented, input from the external device(s) shall initiate the network change regardless of the identity of the current network and how it was selected. (M) 5.2.3.25ix Automatic network selection is not suitable for use in areas where there is a risk that the Cab radio will change to a foreign network unpredictably. (I)

-- L0 spec

structure Input where
  currentNetwork : String
  externalDevice : String
  deriving DecidableEq, Repr

structure Output where
  networkSelected : Bool
  newNetwork      : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentNetwork ≠ "" ∧ i.externalDevice ≠ ""
  post := fun i o => (o.networkSelected = true ↔
    (i.currentNetwork = "foreign" → o.newNetwork ≠ i.currentNetwork) ∧
    (i.currentNetwork ≠ "foreign" → o.newNetwork = i.currentNetwork)) ∧
    (o.networkSelected = false → o.newNetwork = i.currentNetwork)

example : Spec.pre { currentNetwork := "a", externalDevice := "device1" } ∧ Spec.post { currentNetwork := "a", externalDevice := "device1" } { networkSelected := true, newNetwork := "a" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { networkSelected := decide (x.currentNetwork = "foreign"), newNetwork := x.currentNetwork }
