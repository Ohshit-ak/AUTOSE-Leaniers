import ContractForge
open ContractForge

-- REQ-5#3: Sorting results should take less than 0.1 seconds.

-- L0 spec

structure Input where
  query          : String
  items          : List String
  includeArchive : Bool
  elapsedMicros  : Nat
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => (∀ it ∈ o.results, it ∈ i.items ∧ it.length ≤ 10) ∧
                     o.elapsedMicros < 100000

example : Spec.pre { query := "cats", includeArchive := false,
                     items := ["cats", "dogs", "birds"], elapsedMicros := 90000 } ∧
          Spec.post { query := "cats", includeArchive := false,
                      items := ["cats", "dogs", "birds"], elapsedMicros := 90000 }
                    { results := ["cats"], elapsedMicros := 90000 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  query          : String
  items          : List String
  includeArchive : Bool
  elapsedMicros  : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.query ≠ ""
  post := fun i m => m.query = i.query ∧ m.includeArchive = i.includeArchive ∧
                     m.elapsedMicros = i.elapsedMicros ∧ m.items = i.items

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.query ≠ "" ∧ m.elapsedMicros < 100000
  post := fun m o => (∀ it ∈ o.results, it ∈ m.items ∧ it.length ≤ 10) ∧
                     o.elapsedMicros = m.elapsedMicros

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  simp only at h
  exact h.2.2

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at hp hq ho
  rw [ho, hp, hq]