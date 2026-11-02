import ContractForge
open ContractForge

-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  ip : String
  failedAttempts : Nat
  maxAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  ip : String
  blocked : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.failedAttempts < i.maxAttempts
  post := fun i o => (o.blocked = true ↔ i.failedAttempts + 1 = i.maxAttempts) ∧
                     (o.blocked = false → o.failedAttempts = i.failedAttempts)

example : Spec.pre { ip := "192.168.1.1", failedAttempts := 5, maxAttempts := 10 } ∧
          Spec.post { ip := "192.168.1.1", failedAttempts := 5, maxAttempts := 10 }
                    { ip := "192.168.1.1", blocked := true, failedAttempts := 10 } := by
  unfold Spec; decide
