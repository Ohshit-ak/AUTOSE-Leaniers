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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  succeeded : Bool
  abandoned : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def ComputeElapsedContract : Contract Input Mid where
  pre  := fun i => i.retryTimer = 30
  post := fun i m => m.elapsedMicros = i.retryTimer * 1000000 ∧
                     (m.succeeded = true ↔ i.retryTimer * 1000000 ≤ 30000000) ∧
                     (m.abandoned = true → i.retryTimer * 1000000 ≤ 30000000)

def FinalizeOutcomeContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => o.succeeded = m.succeeded ∧
                     o.abandoned = m.abandoned ∧
                     o.elapsedMicros = m.elapsedMicros ∧
                     (o.succeeded = true ↔ o.elapsedMicros ≤ 30000000) ∧
                     (o.abandoned = true → o.elapsedMicros ≤ 30000000)

theorem po1 : Contract.Compatible ComputeElapsedContract FinalizeOutcomeContract := by
  discharge_po1 [ComputeElapsedContract, FinalizeOutcomeContract, Spec]

theorem po2 : Contract.Refines (ComputeElapsedContract.seq FinalizeOutcomeContract) Spec := by
  discharge_po2 [ComputeElapsedContract, FinalizeOutcomeContract, Spec]

-- L2 ComputeElapsedContract (success=True)

def ComputeElapsedContractImpl (x : Input) : Mid :=
  { succeeded := if x.retryTimer * 1000000 ≤ 30000000 then true else false,
    abandoned := x.abandoned, elapsedMicros := x.retryTimer * 1000000 }

theorem ComputeElapsedContractImpl_ok : ComputeElapsedContract.Satisfies ComputeElapsedContractImpl := by
  discharge_po3 [ComputeElapsedContract, ComputeElapsedContractImpl]

-- L2 FinalizeOutcomeContract (success=False)

def FinalizeOutcomeContractImpl (x : Mid) : Output :=
  { succeeded := x.succeeded, abandoned := x.abandoned, elapsedMicros := x.elapsedMicros }
