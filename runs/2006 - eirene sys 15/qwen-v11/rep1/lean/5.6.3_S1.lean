import ContractForge
open ContractForge

-- 5.6.3/S1: A means of directed network selection should be provided to ensure that the MS registers with the required network.
-- compiles: True · rejects_bad_example: True · checked: True

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
