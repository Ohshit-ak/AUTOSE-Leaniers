-- DD-password: Password of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)
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
    (4 ≤ i.raw.length ∧ i.raw.length ≤ 10 ∧
     i.raw.toList.all (·.isAlphanum) = true)

example : Spec.pre { raw := "A1b2" } ∧
          Spec.post { raw := "A1b2" } { valid := true } := by
  unfold Spec; decide
