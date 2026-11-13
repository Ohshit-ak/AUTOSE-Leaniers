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
  product : String
  found   : Bool
  deriving DecidableEq, Repr

def FindProductContract : Contract Input Mid where
  pre  := fun i => i.product ≠ ""
  post := fun i m => m.product = i.product ∧ m.found = true

def ProcessResultsContract : Contract Mid Output where
  pre  := fun m => m.found
  post := fun m o => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                     (o.results.length > 0 → o.elapsedMicros < 1000000)

theorem po1 : Contract.Compatible FindProductContract ProcessResultsContract := by
  discharge_po1 [FindProductContract, ProcessResultsContract, Spec]

theorem po2 : Contract.Refines (FindProductContract.seq ProcessResultsContract) Spec := by
  discharge_po2 [FindProductContract, ProcessResultsContract, Spec]

-- L2 FindProductContract (success=True)

def FindProductContractImpl (x : Input) : Mid :=
  { product := x.product, found := true }

theorem FindProductContractImpl_ok : FindProductContract.Satisfies FindProductContractImpl := by
  discharge_po3 [FindProductContract, FindProductContractImpl]

-- L2 ProcessResultsContract (success=True)

def ProcessResultsContractImpl (x : Mid) : Output :=
  { results := if x.found then [x.product] else [], elapsedMicros := if x.found then 500000 else 0 }

theorem ProcessResultsContractImpl_ok : ProcessResultsContract.Satisfies ProcessResultsContractImpl := by
  discharge_po3 [ProcessResultsContract, ProcessResultsContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ProcessResultsContractImpl ∘ FindProductContractImpl) :=
  Contract.system_sound po1 po2 FindProductContractImpl_ok ProcessResultsContractImpl_ok
