-- 5.5/R5: The system shall validate email address existence.
-- checked: False

structure Input where
  email : String
  deriving DecidableEq, Repr

structure Output where
  exists : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.exists = true ↔ i.email.length > 0 ∧ i.email.toList.contains '@'

example : Spec.pre { email := "test@example.com" } ∧
          Spec.post { email := "test@example.com" } { exists := true } := by
  unfold Spec; decide
