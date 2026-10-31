-- 5.5/R5: The system shall validate email address existence.
-- checked: True

structure Input where
  email : String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.exists_ = true ↔ i.email.toList.any (· = '@') = true

example : Spec.pre { email := "test@example.com" } ∧
          Spec.post { email := "test@example.com" } { exists_ := true } := by
  unfold Spec; decide
