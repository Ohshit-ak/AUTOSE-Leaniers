import ContractForge
open ContractForge

-- DD-text-description: special description of the selected item; maximum 100 alphabetic characters
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 100 ∧
     i.raw.toList.all (·.isAlpha) = true)

example : Spec.pre { raw := "short description" } ∧ Spec.post { raw := "short description" } { valid := false } := by
  unfold Spec; decide
