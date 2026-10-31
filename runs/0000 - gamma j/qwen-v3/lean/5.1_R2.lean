-- 5.1/R2: The system shall be able to handle 1000 customers logged in concurrently at the same time.
-- checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  concurrentUsers : Nat
  maxLatency      : Nat
  maxThroughput   : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.concurrentUsers ≥ 1000 ∧
                     o.maxLatency ≤ 100 ∧
                     o.maxThroughput ≥ 500

example : Spec.pre { } ∧
          Spec.post { } { concurrentUsers := 1000, maxLatency := 50, maxThroughput := 600 } := by
  unfold Spec; decide
