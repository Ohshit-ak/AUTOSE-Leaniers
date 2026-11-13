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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  selectedNetwork : String
  failedAttempts  : Nat
  safeAreas       : List String
  deriving DecidableEq, Repr

def ComputeSelectionContract : Contract Input Mid where
  pre  := fun i => i.cabNetwork ≠ "" ∧ i.safeAreas.Nodup
  post := fun i m => m.failedAttempts = 0 ↔
                     ∃ area ∈ i.safeAreas, area = i.cabNetwork

def FinalizeOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => m.failedAttempts > 0 →
                     o.selectedNetwork = m.selectedNetwork ∧
                     m.safeAreas.contains m.selectedNetwork = false
