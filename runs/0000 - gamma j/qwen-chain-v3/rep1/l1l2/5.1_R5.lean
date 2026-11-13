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
  itemsMatch : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def MatchItemsContract : Contract Input Mid where
  pre  := fun i => i.product ≠ ""
  post := fun i m => m.product = i.product ∧ m.itemsMatch = i.items ∧ m.elapsedMicros = 0

def ProcessResultsContract : Contract Mid Output where
  pre  := fun m => m.elapsedMicros = 0
  post := fun m o => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                     (o.results.length > 0 → o.elapsedMicros < 1000000)

theorem po1 : Contract.Compatible MatchItemsContract ProcessResultsContract := by
  discharge_po1 [MatchItemsContract, ProcessResultsContract, Spec]

theorem po2 : Contract.Refines (MatchItemsContract.seq ProcessResultsContract) Spec := by
  discharge_po2 [MatchItemsContract, ProcessResultsContract, Spec]

-- L2 MatchItemsContract (success=True)

def MatchItemsContractImpl (x : Input) : Mid :=
  { product := x.product, itemsMatch := x.items, elapsedMicros := 0 }

theorem MatchItemsContractImpl_ok : MatchItemsContract.Satisfies MatchItemsContractImpl := by
  discharge_po3 [MatchItemsContract, MatchItemsContractImpl]

-- L2 ProcessResultsContract (success=True)

def ProcessResultsContractImpl (x : Mid) : Output :=
  { results := if x.elapsedMicros = 0 then [] else [x.product], elapsedMicros := x.elapsedMicros }

theorem ProcessResultsContractImpl_ok : ProcessResultsContract.Satisfies ProcessResultsContractImpl := by
  discharge_po3 [ProcessResultsContract, ProcessResultsContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ProcessResultsContractImpl ∘ MatchItemsContractImpl) :=
  Contract.system_sound po1 po2 MatchItemsContractImpl_ok ProcessResultsContractImpl_ok
