-- DD-text-description: special description of the selected item; maximum 100 alphabetic characters
-- checked: True

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

example : Spec.pre { raw := "shortdesc" } ∧
          Spec.post { raw := "shortdesc" } { valid := true } := by
  unfold Spec; decide
