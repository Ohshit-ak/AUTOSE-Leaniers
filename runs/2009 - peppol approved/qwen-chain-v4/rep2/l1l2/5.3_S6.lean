import ContractForge
open ContractForge

-- 5.3/S6: The spreadsheet will be used in the project in order to maintain, adapt and perform change management to the requirements over the project lifetime.

-- L0 spec

structure Requirement where
  id      : Nat
  text    : String
  status  : String
  deriving DecidableEq, Repr

structure Input where
  requirements : List Requirement
  deriving DecidableEq, Repr

structure Output where
  updatedRequirements : List Requirement
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.requirements.Nodup
  post := fun i o => o.updatedRequirements = i.requirements ∧
                     o.updatedRequirements.length = i.requirements.length ∧
                     (∀ r ∈ o.updatedRequirements, r.id = r.id)

example : Spec.pre { requirements := [{ id := 1, text := "Requirement 1", status := "Open" },
                                        { id := 2, text := "Requirement 2", status := "Closed" }] } ∧
          Spec.post { requirements := [{ id := 1, text := "Requirement 1", status := "Open" },
                                        { id := 2, text := "Requirement 2", status := "Closed" }] }
                    { updatedRequirements := [{ id := 1, text := "Requirement 1", status := "Open" },
                                              { id := 2, text := "Requirement 2", status := "Closed" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { updatedRequirements := x.requirements }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
