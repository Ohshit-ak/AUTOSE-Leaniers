import ContractForge
open ContractForge

-- 3.13.3/S1: REQ-17: An entry must be selected to be deleted

-- L0 spec

structure Entry where
  id   : Nat
  data : String
  deriving DecidableEq, Repr

structure Input where
  entries   : List Entry
  selectedId: Nat
  deriving DecidableEq, Repr

structure Output where
  deleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selectedId ≠ 0 ∧ ∃ e ∈ i.entries, e.id = i.selectedId
  post := fun i o => o.deleted = true ↔ i.selectedId ≠ 0 ∧ ∃ e ∈ i.entries, e.id = i.selectedId

example : Spec.pre { entries := [{ id := 1, data := "entry1" }, { id := 2, data := "entry2" }], selectedId := 2 } ∧ Spec.post { entries := [{ id := 1, data := "entry1" }, { id := 2, data := "entry2" }], selectedId := 2 } { deleted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { deleted := decide (x.selectedId ≠ 0 ∧ ∃ e ∈ x.entries, e.id = x.selectedId) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
