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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def ComputeResultsContract : Contract Input Mid where
  pre  := fun i => i.product ≠ ""
  post := fun i m => m.results.length = 0 ↔ m.elapsedMicros = 0

def ProcessResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => m.results.length > 0 → o.elapsedMicros < 1000000 ∧
                     o.results.length = m.results.length
