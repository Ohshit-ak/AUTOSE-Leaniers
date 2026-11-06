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

-- Component 1: Query is non-empty
def QueryNonEmptyContract : Contract Input Input where
  pre  := fun i => i.query ≠ ""
  post := fun i i' => i' = i

-- Component 2: Filter items based on query
def FilterItemsContract : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => (∀ it ∈ o.results, it ∈ i.items ∧ it.length ≤ 10) ∧
                     o.elapsedMicros = i.elapsedMicros

-- Prove PO1: Each component's assumption follows from its predecessor's guarantee
example : Contract.Compatible QueryNonEmptyContract Spec := by
  unfold Contract.Compatible; unfold Spec; unfold QueryNonEmptyContract
  intros i i' h
  simp [h]
  exact (i.query ≠ "").trans (i'.query ≠ "")

example : Contract.Compatible FilterItemsContract QueryNonEmptyContract := by
  unfold Contract.Compatible; unfold FilterItemsContract; unfold QueryNonEmptyContract
  intros i i' h
  simp [h]
  exact (i = i').trans (i = i')

-- Prove PO2: The composition refines the spec
example : Contract.Refines (QueryNonEmptyContract.seq FilterItemsContract) Spec := by
  unfold Contract.Refines; unfold QueryNonEmptyContract; unfold FilterItemsContract; unfold Spec
  intros i o h
  simp [h]
  exact (Spec.post i o).trans (FilterItemsContract.post i o).trans (QueryNonEmptyContract.post i i)