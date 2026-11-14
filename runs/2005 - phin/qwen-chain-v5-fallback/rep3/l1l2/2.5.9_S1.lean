import ContractForge
open ContractForge

-- 2.5.9/S1: Systems supporting OM must be able to receive, parse and process messages for countermeasures that have been administered.

-- L0 spec

structure Countermeasure where
  id       : Nat
  patient  : String
  dose     : Nat
  adminDate: String
  deriving DecidableEq, Repr

structure Message where
  countermeasures : List Countermeasure
  deriving DecidableEq, Repr

structure Input where
  countermeasures : List Countermeasure
  deriving DecidableEq, Repr

structure Output where
  processed : Bool
  countermeasures : List Countermeasure
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.countermeasures.Nodup
  post := fun i o => o.processed = true ∧
    (o.processed = false → o.countermeasures = i.countermeasures) ∧
    (∃ cm ∈ i.countermeasures, o.processed = true →
      o.countermeasures.contains cm ∧
      o.countermeasures.count cm = i.countermeasures.count cm)

example : Spec.pre { countermeasures := [{ id := 1, patient := "P1", dose := 100, adminDate := "2023-01-01" }] } ∧
          Spec.post { countermeasures := [{ id := 1, patient := "P1", dose := 100, adminDate := "2023-01-01" }] }
                    { processed := true, countermeasures := [{ id := 1, patient := "P1", dose := 100, adminDate := "2023-01-01" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  processed : Bool
  cm        : Countermeasure
  countermeasures : List Countermeasure
  deriving DecidableEq, Repr

def ProcessCountermeasuresContract : Contract Input Mid where
  pre  := fun i => i.countermeasures.Nodup
  post := fun i m => (m.processed = true ∧
    (m.processed = false → m.countermeasures = i.countermeasures) ∧
    (∃ cm ∈ i.countermeasures, m.processed = true →
      m.countermeasures.contains cm ∧
      m.countermeasures.count cm = i.countermeasures.count cm)) ∧
    (∃ cm ∈ i.countermeasures, m.processed = true →
      m.cm = cm ∧ m.countermeasures.count cm = 1)

def CollectResultsContract : Contract Mid Output where
  pre  := fun m => m.processed
  post := fun m o => o.processed = m.processed ∧
    (o.processed = true → o.countermeasures = m.countermeasures)

theorem po1 : Contract.Compatible ProcessCountermeasuresContract CollectResultsContract := by
  discharge_po1 [ProcessCountermeasuresContract, CollectResultsContract, Spec]

theorem po2 : Contract.Refines (ProcessCountermeasuresContract.seq CollectResultsContract) Spec := by
  discharge_po2 [ProcessCountermeasuresContract, CollectResultsContract, Spec]

-- L2 ProcessCountermeasuresContract (success=False)

def ProcessCountermeasuresContractImpl (x : Input) : Mid :=
  { processed := true,
    cm := x.countermeasures.head,
    countermeasures := x.countermeasures }

-- L2 CollectResultsContract (success=True)

def CollectResultsContractImpl (x : Mid) : Output :=
  { processed := x.processed,
    countermeasures := x.countermeasures }

theorem CollectResultsContractImpl_ok : CollectResultsContract.Satisfies CollectResultsContractImpl := by
  discharge_po3 [CollectResultsContract, CollectResultsContractImpl]
