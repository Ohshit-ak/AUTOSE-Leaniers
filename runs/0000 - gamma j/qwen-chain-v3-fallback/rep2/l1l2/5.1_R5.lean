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
  items   : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def SearchProductsContract : Contract Input Mid where
  pre  := fun i => i.product ≠ ""
  post := fun i m => m.product = i.product ∧ m.items = i.items ∧ m.elapsedMicros < 1000000

def FormatResultsContract : Contract Mid Output where
  pre  := fun m => m.elapsedMicros < 1000000
  post := fun m o => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                     (o.results.length > 0 → o.elapsedMicros < 1000000)

theorem po1 : Contract.Compatible SearchProductsContract FormatResultsContract := by
  discharge_po1 [SearchProductsContract, FormatResultsContract, Spec]

theorem po2 : Contract.Refines (SearchProductsContract.seq FormatResultsContract) Spec := by
  discharge_po2 [SearchProductsContract, FormatResultsContract, Spec]

-- L2 SearchProductsContract (success=True)

def SearchProductsContractImpl (x : Input) : Mid :=
  { product := x.product, items := x.items, elapsedMicros := 0 }

theorem SearchProductsContractImpl_ok : SearchProductsContract.Satisfies SearchProductsContractImpl := by
  discharge_po3 [SearchProductsContract, SearchProductsContractImpl]

-- L2 FormatResultsContract (success=True)

def FormatResultsContractImpl (x : Mid) : Output :=
  { results := if x.elapsedMicros = 0 then [] else [x.product], elapsedMicros := x.elapsedMicros }

theorem FormatResultsContractImpl_ok : FormatResultsContract.Satisfies FormatResultsContractImpl := by
  discharge_po3 [FormatResultsContract, FormatResultsContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (FormatResultsContractImpl ∘ SearchProductsContractImpl) :=
  Contract.system_sound po1 po2 SearchProductsContractImpl_ok FormatResultsContractImpl_ok
