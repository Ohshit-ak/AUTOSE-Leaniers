import ContractForge
open ContractForge

-- 4.1.1.3b: It shall also be possible, to allow the driver to change the adhesion conditions; in this case information from trackside has priority.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  adhesionConditions : String
  tracksideInfo      : String
  deriving DecidableEq, Repr

structure Output where
  adhesionConditions : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.adhesionConditions ≠ "" ∧ i.tracksideInfo ≠ ""
  post := fun i o => o.adhesionConditions = if i.tracksideInfo = i.adhesionConditions then i.adhesionConditions
                                                  else i.tracksideInfo

example : Spec.pre { adhesionConditions := "dry", tracksideInfo := "wet" } ∧
          Spec.post { adhesionConditions := "dry", tracksideInfo := "wet" }
                    { adhesionConditions := "wet" } := by
  unfold Spec; decide
