import ContractForge
open ContractForge

-- 5.6.3/S1: A means of directed network selection should be provided to ensure that the MS registers with the required network.

-- L0 spec

structure Input where
  networkSelection : String
  network          : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  network    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networkSelection ≠ "" ∧ i.networkSelection ≠ i.network
  post := fun i o => (o.registered = true ↔ i.networkSelection = o.network) ∧
                     (o.registered = false →
                      (i.networkSelection = i.network ∧ o.network = i.network) ∨
                      (i.networkSelection ≠ i.network ∧ o.network = i.networkSelection))

example : Spec.pre { networkSelection := "requiredNetwork", network := "currentNetwork" } ∧ Spec.post { networkSelection := "requiredNetwork", network := "currentNetwork" } { registered := true, network := "requiredNetwork" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { registered := decide (x.networkSelection = x.network), network := x.network }
