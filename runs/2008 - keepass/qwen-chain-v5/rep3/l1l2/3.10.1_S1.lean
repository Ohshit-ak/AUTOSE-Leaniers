import ContractForge
open ContractForge

-- 3.10.1/S1: The user can add a new entry on the database by clicking add entry on the main menu.

-- L0 spec

structure Entry where
  description : String
  deriving DecidableEq, Repr

structure Input where
  description : String
  deriving DecidableEq, Repr

structure Output where
  added : Bool
  description : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.description ≠ ""
  post := fun i o => o.added = true ∧
                     (o.description = i.description ↔ i.description ≠ "")

example : Spec.pre { description := "New entry description" } ∧
          Spec.post { description := "New entry description" }
                    { added := true, description := "New entry description" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { added := true,
    description := if x.description ≠ "" then x.description else "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
