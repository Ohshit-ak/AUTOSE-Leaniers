import ContractForge
open ContractForge

-- 3.13.1/S1: The user can delete an existing entry by selecting it and then by clicking delete entry.

-- L0 spec

structure Entry where
  id   : Nat
  data : String
  deriving DecidableEq, Repr

structure Input where
  entries : List Entry
  selected : Option Nat
  deriving DecidableEq, Repr

structure Output where
  entries : List Entry
  deleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selected.isSome
  post := fun i o => (o.deleted = true ↔
    ∃ id ∈ i.entries.map (fun e => e.id), id = i.selected.getD 0) ∧
    o.entries = i.entries.filter (fun e => e.id ≠ i.selected.getD 0)

example : Spec.pre { entries := [{ id := 1, data := "entry1" }, { id := 2, data := "entry2" }],
                     selected := some 1 } ∧
          Spec.post { entries := [{ id := 1, data := "entry1" }, { id := 2, data := "entry2" }],
                      selected := some 1 }
                    { entries := [{ id := 2, data := "entry2" }], deleted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { entries := x.entries.filter (fun e => e.id ≠ x.selected.getD 0),
    deleted := decide (∃ id ∈ x.entries.map (fun e => e.id), id = x.selected.getD 0) }
