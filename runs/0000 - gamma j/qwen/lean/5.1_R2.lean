-- 5.1/R2: The system shall be able to handle 1000 customers logged in concurrently at the same time.
-- checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  concurrentUsers : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.concurrentUsers ≥ 1000

example : Spec.pre { } ∧ Spec.post { } { concurrentUsers := 1000 } := by
  unfold Spec; decide
