-- 5.3/R5: The system shall detect consecutive failed login attempts.
-- checked: True

structure Input where
  username : String
  password : String
  failedAttempts : Nat
  maxFailedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  detected : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.maxFailedAttempts
  post := fun i o => o.detected = true ↔ i.failedAttempts ≥ i.maxFailedAttempts

example : Spec.pre { username := "user", password := "pass", failedAttempts := 5, maxFailedAttempts := 3 } ∧
          Spec.post { username := "user", password := "pass", failedAttempts := 5, maxFailedAttempts := 3 }
                    { detected := true } := by
  unfold Spec; decide
