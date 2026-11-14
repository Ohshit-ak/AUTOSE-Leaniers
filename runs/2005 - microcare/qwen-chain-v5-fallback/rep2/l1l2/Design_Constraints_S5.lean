import ContractForge
open ContractForge

-- Design Constraints/S5: On capture of any duplicate name the system will give a warning message to have the duplicate name or to change the name.

-- L0 spec

structure Name where
  value : String
  deriving DecidableEq, Repr

structure Input where
  names : List Name
  deriving DecidableEq, Repr

structure Output where
  warning : Bool
  newNames : List Name
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.names.Nodup
  post := fun i o => o.warning = true ↔
    ∃ n1 ∈ i.names, ∃ n2 ∈ i.names, n1 ≠ n2 ∧ n1.value = n2.value ∧
    o.newNames = i.names.filter (fun n => n.value ≠ n1.value ∧ n.value ≠ n2.value)

example : Spec.pre { names := [{ value := "John" }, { value := "Doe" }] } ∧
          Spec.post { names := [{ value := "John" }, { value := "Doe" }] }
                    { warning := false, newNames := [{ value := "John" }, { value := "Doe" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { warning := decide (∃ n1 ∈ x.names, ∃ n2 ∈ x.names, n1 ≠ n2 ∧ n1.value = n2.value),
    newNames := x.names.filter (fun n => ∀ n1 ∈ x.names, n1 ≠ n ∧ n1.value ≠ n.value) }
