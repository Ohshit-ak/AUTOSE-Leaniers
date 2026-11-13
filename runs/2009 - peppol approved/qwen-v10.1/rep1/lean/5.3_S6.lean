import ContractForge
open ContractForge

-- 5.3/S6: The spreadsheet will be used in the project in order to maintain, adapt and perform change management to the requirements over the project lifetime.
-- compiles: True · rejects_bad_example: None · checked: True

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
