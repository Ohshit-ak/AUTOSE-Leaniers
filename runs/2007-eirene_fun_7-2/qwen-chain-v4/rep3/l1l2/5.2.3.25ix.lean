import ContractForge
open ContractForge

-- 5.2.3.25ix: 5.2.3.25ix Automatic network selection is not suitable for use in areas where there is a risk that the Cab radio will change to a foreign network unpredictably. (I)

-- L0 spec

structure Input where
  cabNetwork : String
  safeAreas  : List String
  deriving DecidableEq, Repr

structure Output where
  selectedNetwork : String
  failedAttempts  : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabNetwork ≠ "" ∧ i.safeAreas.Nodup
  post := fun i o =>
    (o.failedAttempts = 0 ↔
      ∃ area ∈ i.safeAreas, area = i.cabNetwork) ∧
    (o.failedAttempts > 0 →
      o.selectedNetwork = i.cabNetwork ∧
      i.safeAreas.contains o.selectedNetwork = false)

example : Spec.pre { cabNetwork := "A1", safeAreas := ["A1", "A2"] } ∧
          Spec.post { cabNetwork := "A1", safeAreas := ["A1", "A2"] }
                    { selectedNetwork := "A1", failedAttempts := 0 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  selectedNetwork : String
  failedAttempts  : Nat
  safeAreas       : List String
  deriving DecidableEq, Repr

def ComputeSelectionContract : Contract Input Mid where
  pre  := fun i => i.cabNetwork ≠ "" ∧ i.safeAreas.Nodup
  post := fun i m => m.selectedNetwork = i.cabNetwork ∧
                     (m.failedAttempts = 0 ↔
                       ∃ area ∈ i.safeAreas, area = i.cabNetwork) ∧
                     (m.failedAttempts > 0 →
                       i.safeAreas.contains m.selectedNetwork = false)

def ProcessAttemptsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.selectedNetwork = m.selectedNetwork ∧
                     o.failedAttempts = m.failedAttempts ∧
                     (o.failedAttempts = 0 ↔
                       ∃ area ∈ m.safeAreas, area = m.selectedNetwork) ∧
                     (o.failedAttempts > 0 →
                       m.safeAreas.contains o.selectedNetwork = false)

theorem po1 : Contract.Compatible ComputeSelectionContract ProcessAttemptsContract := by
  discharge_po1 [ComputeSelectionContract, ProcessAttemptsContract, Spec]

theorem po2 : Contract.Refines (ComputeSelectionContract.seq ProcessAttemptsContract) Spec := by
  discharge_po2 [ComputeSelectionContract, ProcessAttemptsContract, Spec]

-- L2 ComputeSelectionContract (success=False)

def ComputeSelectionContractImpl (x : Input) : Mid :=
  { selectedNetwork := if x.safeAreas.contains x.cabNetwork then x.cabNetwork else "",
    failedAttempts := 0,
    safeAreas := x.safeAreas }

-- L2 ProcessAttemptsContract (success=False)

def ProcessAttemptsContractImpl (x : Mid) : Output :=
  { selectedNetwork := x.selectedNetwork, failedAttempts := x.failedAttempts }
