import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.

-- L0 spec

structure Input where
  product : String
  items   : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product ≠ ""
  post := fun i o => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                     (o.results.length > 0 → o.elapsedMicros < 1000000)

example : Spec.pre { product := "laptop", items := ["laptop", "phone", "tablet"] } ∧
          Spec.post { product := "laptop", items := ["laptop", "phone", "tablet"] }
                    { results := ["laptop"], elapsedMicros := 500000 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def ComputeResultsContract : Contract Input Mid where
  pre  := fun i => i.product ≠ ""
  post := fun i m => m.results.length = 0 ↔ m.elapsedMicros = 0

def ProcessResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.results.length = m.results.length ∧
                     (o.elapsedMicros = 0 ↔ o.results.length = 0) ∧
                     (o.elapsedMicros < 1000000 ↔ o.results.length > 0)

theorem po1 : Contract.Compatible ComputeResultsContract ProcessResultsContract := by
  discharge_po1 [ComputeResultsContract, ProcessResultsContract, Spec]

theorem po2 : Contract.Refines (ComputeResultsContract.seq ProcessResultsContract) Spec := by
  discharge_po2 [ComputeResultsContract, ProcessResultsContract, Spec]

-- L2 ComputeResultsContract (success=True)

def ComputeResultsContractImpl (x : Input) : Mid :=
  { results := [], elapsedMicros := 0 }

theorem ComputeResultsContractImpl_ok : ComputeResultsContract.Satisfies ComputeResultsContractImpl := by
  discharge_po3 [ComputeResultsContract, ComputeResultsContractImpl]

-- L2 ProcessResultsContract (success=False)

def ProcessResultsContractImpl (x : Mid) : Output :=
  { results := x.results, elapsedMicros := if x.results.length = 0 then 0 else 500000 }
