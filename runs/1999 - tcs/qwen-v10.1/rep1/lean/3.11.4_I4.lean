import ContractForge
open ContractForge

-- 3.11.4/I4: TCM denotes Total Corrective Maintenance
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  failedAttempts : Nat
  succeeded      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.failedAttempts < 3
  post := fun i o => o.succeeded ↔ i.failedAttempts < 3 ∧
                     o.failedAttempts = i.failedAttempts + 1

example : Spec.pre { failedAttempts := 2 } ∧
          Spec.post { failedAttempts := 2 }
                    { succeeded := true, failedAttempts := 3 } := by
  unfold Spec; decide
