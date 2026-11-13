import ContractForge
open ContractForge

-- 5.6.3/S1: A means of directed network selection should be provided to ensure that the MS registers with the required network.

-- L0 spec

structure Input where
  networkSelection : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  network    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networkSelection ≠ ""
  post := fun i o => (o.registered = true ↔ o.network = i.networkSelection) ∧
                     (o.registered = false → o.network = "")

example : Spec.pre { networkSelection := "10.0.0.1" } ∧
          Spec.post { networkSelection := "10.0.0.1" }
                    { registered := true, network := "10.0.0.1" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  network : String
  isRegistered : Bool
  deriving DecidableEq, Repr

def RegisterToNetworkContract : Contract Input Mid where
  pre  := fun i => i.networkSelection ≠ ""
  post := fun i m => m.network = i.networkSelection ∧ m.isRegistered = (i.networkSelection = i.networkSelection)

def SetRegistrationStatusContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.registered = true ↔ m.isRegistered) ∧
                     (o.registered = false → m.isRegistered = false)
