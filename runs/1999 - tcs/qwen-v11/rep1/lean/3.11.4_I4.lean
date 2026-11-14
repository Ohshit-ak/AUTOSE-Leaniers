import ContractForge
open ContractForge

-- 3.11.4/I4: TCM denotes Total Corrective Maintenance
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  failedAttempts : Nat
  totalMaintenance : Nat
  deriving DecidableEq, Repr

structure Output where
  failedAttempts : Nat
  totalMaintenance : Nat
  succeeded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.failedAttempts < i.totalMaintenance
  post := fun i o => o.failedAttempts = i.failedAttempts + 1 ∧
                     (o.succeeded = true ↔ i.totalMaintenance > i.failedAttempts)

example : Spec.pre { failedAttempts := 2, totalMaintenance := 5 } ∧
          Spec.post { failedAttempts := 2, totalMaintenance := 5 }
                    { failedAttempts := 3, totalMaintenance := 5, succeeded := true } := by
  unfold Spec; decide
