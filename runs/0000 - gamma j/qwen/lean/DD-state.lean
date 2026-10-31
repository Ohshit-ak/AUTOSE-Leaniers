-- DD-state: Name of the state for the above city; maximum 20 characters alphabetic string
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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 20 ∧
     i.raw.toList.all (·.isAlpha) = true)

example : Spec.pre { raw := "CityName" } ∧
          Spec.post { raw := "CityName" } { valid := true } := by
  unfold Spec; decide
