import ContractForge
open ContractForge

-- 5.2.3.25iii: 5.2.3.25iii If directed network selection is implemented and voice calls are ongoing at the time when the external device attempts to trigger a network change, an audible and visual indication shall be given to the driver and network change shall be deferred until the call is terminated or until coverage of the current network is lost. (M)

-- L0 spec

structure Input where
  directedNetworkSelection : Bool
  ongoingCalls : Nat
  deriving DecidableEq, Repr

structure Output where
  deferred : Bool
  indication : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.directedNetworkSelection = true ∧ i.ongoingCalls > 0
  post := fun i o => (o.deferred = true ↔ i.directedNetworkSelection = true ∧ i.ongoingCalls > 0) ∧
                     (o.indication = true ↔ i.directedNetworkSelection = true ∧ i.ongoingCalls > 0) ∧
                     (o.deferred = true → o.indication = true) ∧
                     (o.deferred = false → (i.ongoingCalls = 0 ∨ i.directedNetworkSelection = false))

example : Spec.pre { directedNetworkSelection := true, ongoingCalls := 5 } ∧
          Spec.post { directedNetworkSelection := true, ongoingCalls := 5 }
                    { deferred := true, indication := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  deferred : Bool
  directedNetworkSelection : Bool
  ongoingCalls : Nat
  deriving DecidableEq, Repr

def ComputeDeferredContract : Contract Input Mid where
  pre  := fun i => i.directedNetworkSelection = true ∧ i.ongoingCalls > 0
  post := fun i m => m.deferred = true ↔ i.directedNetworkSelection = true ∧ i.ongoingCalls > 0

def PropagateIndicationContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.indication = true ↔ m.deferred = true) ∧
                     (o.deferred = true → o.indication = true) ∧
                     (o.deferred = false → (m.directedNetworkSelection = false ∨ m.ongoingCalls = 0))
