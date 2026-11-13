import ContractForge
open ContractForge

-- 7.2.3.9i: 7.2.3.9i It shall be possible for a user to override the automatic network selection manually. This function shall not be available during calls. (M) Register and deregister functional number

-- L0 spec

structure Input where
  userOverride : Bool
  ongoingCall : Bool
  networkSelection : String
  deriving DecidableEq, Repr

structure Output where
  networkSelection : String
  overridingPossible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => ¬i.ongoingCall
  post := fun i o => (o.overridingPossible = true ↔ i.userOverride = true) ∧
                     (o.networkSelection = i.networkSelection) ∧
                     (o.overridingPossible = false → o.networkSelection = i.networkSelection)

example : Spec.pre { userOverride := true, ongoingCall := false, networkSelection := "NetworkA" } ∧
          Spec.post { userOverride := true, ongoingCall := false, networkSelection := "NetworkA" }
                    { overridingPossible := true, networkSelection := "NetworkA" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  networkSelection : String
  overridingPossible : Bool
  deriving DecidableEq, Repr

def ComputeMidContract : Contract Input Mid where
  pre  := fun i => ¬i.ongoingCall
  post := fun i m => m.networkSelection = i.networkSelection ∧ m.overridingPossible = (i.userOverride = true)

def ProduceOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.overridingPossible = true ↔ m.overridingPossible = true) ∧
                     (o.networkSelection = m.networkSelection)
