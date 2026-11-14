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
  deriving DecidableEq, Repr

def ComputeSelectionContract : Contract Input Mid where
  pre  := fun i => i.cabNetwork ≠ "" ∧ i.safeAreas.Nodup
  post := fun i m => m.selectedNetwork = i.cabNetwork ∧
                     (m.failedAttempts = 0 ↔
                       ∃ area ∈ i.safeAreas, area = i.cabNetwork) ∧
                     (m.failedAttempts > 0 →
                       i.safeAreas.contains m.selectedNetwork = false)

def UpdateAttemptsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.selectedNetwork = m.selectedNetwork ∧
                     (o.failedAttempts = 0 ↔
                       m.failedAttempts = 0) ∧
                     (o.failedAttempts > 0 →
                       m.failedAttempts > 0 ∧
                       m.failedAttempts = o.failedAttempts)

theorem po1 : Contract.Compatible ComputeSelectionContract UpdateAttemptsContract := by
  discharge_po1 [ComputeSelectionContract, UpdateAttemptsContract, Spec]

theorem po2 : Contract.Refines (ComputeSelectionContract.seq UpdateAttemptsContract) Spec := by
  discharge_po2 [ComputeSelectionContract, UpdateAttemptsContract, Spec]

-- L2 ComputeSelectionContract (success=True)

def ComputeSelectionContractImpl (x : Input) : Mid :=
  { selectedNetwork := x.cabNetwork,
    failedAttempts := if ∃ area ∈ x.safeAreas, area = x.cabNetwork then 0 else 1 }

theorem ComputeSelectionContractImpl_ok : ComputeSelectionContract.Satisfies ComputeSelectionContractImpl := by
  discharge_po3 [ComputeSelectionContract, ComputeSelectionContractImpl]

-- L2 UpdateAttemptsContract (success=True)

def UpdateAttemptsContractImpl (x : Mid) : Output :=
  { selectedNetwork := x.selectedNetwork,
    failedAttempts := if x.failedAttempts = 0 then 0 else x.failedAttempts }

theorem UpdateAttemptsContractImpl_ok : UpdateAttemptsContract.Satisfies UpdateAttemptsContractImpl := by
  discharge_po3 [UpdateAttemptsContract, UpdateAttemptsContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (UpdateAttemptsContractImpl ∘ ComputeSelectionContractImpl) :=
  Contract.system_sound po1 po2 ComputeSelectionContractImpl_ok UpdateAttemptsContractImpl_ok
