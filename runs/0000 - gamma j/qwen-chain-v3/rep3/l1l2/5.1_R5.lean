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
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def FindResultsContract : Contract Input Mid where
  pre  := fun i => i.product ≠ ""
  post := fun i m => m.elapsedMicros < 1000000 ∧ (m.elapsedMicros = 0 ↔ i.items = [])

def ProcessResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                     (o.results.length > 0 → o.elapsedMicros < 1000000 ∧ o.elapsedMicros = m.elapsedMicros)

theorem po1 : Contract.Compatible FindResultsContract ProcessResultsContract := by
  discharge_po1 [FindResultsContract, ProcessResultsContract, Spec]

theorem po2 : Contract.Refines (FindResultsContract.seq ProcessResultsContract) Spec := by
  discharge_po2 [FindResultsContract, ProcessResultsContract, Spec]

-- L2 FindResultsContract (success=True)

def FindResultsContractImpl (x : Input) : Mid :=
  { elapsedMicros := if x.items = [] then 0 else 999999 }

theorem FindResultsContractImpl_ok : FindResultsContract.Satisfies FindResultsContractImpl := by
  discharge_po3 [FindResultsContract, FindResultsContractImpl]

-- L2 ProcessResultsContract (success=False)

def ProcessResultsContractImpl (x : Mid) : Output :=
  { results := [], elapsedMicros := x.elapsedMicros }
