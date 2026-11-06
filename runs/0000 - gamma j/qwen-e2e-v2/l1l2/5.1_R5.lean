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

-- L1 architect (success=False)

structure Mid where
  product : String
  items   : List String
  results : List String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.product ≠ ""
  post := fun i m => m.results.length = 0 ∧ m.elapsedMicros = 0

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.results.length = 0 ∧ m.elapsedMicros = 0
  post := fun m o => o.results.length = m.results.length ∧ o.elapsedMicros < 1000000

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  cases h with h1 h2
  exact h1, h2

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨h1, h2⟩, h3⟩
  simp only at *
  rw [h3, h1, h2]