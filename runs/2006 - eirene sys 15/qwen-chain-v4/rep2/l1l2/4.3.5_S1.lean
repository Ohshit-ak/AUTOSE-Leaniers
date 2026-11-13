import ContractForge
open ContractForge

-- 4.3.5/S1: If a Railway emergency call set up from an EIRENE radio is unsuccessful, the radio shall automatically re-attempt the call setup until the call setup is successful, a retry timer expires (duration 30 seconds, as specified in the [EIRENE FRS]) or the user abandons the call.

-- L0 spec

structure Input where
  retryTimer : Nat
  succeeded  : Bool
  abandoned  : Bool
  deriving DecidableEq, Repr

structure Output where
  succeeded : Bool
  abandoned : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.retryTimer = 30
  post := fun i o => (o.succeeded = true ↔ o.elapsedMicros ≤ 30000000) ∧
                     (o.abandoned = true → o.elapsedMicros ≤ 30000000) ∧
                     (o.succeeded = false → o.elapsedMicros ≤ i.retryTimer * 1000000)

example : Spec.pre { retryTimer := 30, succeeded := false, abandoned := false } ∧ Spec.post { retryTimer := 30, succeeded := false, abandoned := false } { succeeded := true, abandoned := false, elapsedMicros := 2000000 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def ComputeElapsedContract : Contract Input Mid where
  pre  := fun i => i.retryTimer = 30
  post := fun i m => m.elapsedMicros ≤ i.retryTimer * 1000000

def DetermineOutcomeContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.succeeded = true ↔ m.elapsedMicros ≤ 30000000) ∧
                     (o.abandoned = true → m.elapsedMicros ≤ 30000000) ∧
                     (o.succeeded = false → m.elapsedMicros ≤ 30000000)
