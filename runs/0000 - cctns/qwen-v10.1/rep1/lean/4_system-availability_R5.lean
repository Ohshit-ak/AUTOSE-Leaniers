import ContractForge
open ContractForge

-- 4/system-availability/R5: In the event of any software or hardware failure, it must be possible to restore the System (with inline synchronization) within no more than <xx> hours.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  failedAttempts : Nat
  systemState    : String
  deriving DecidableEq, Repr

structure Output where
  restored       : Bool
  systemState    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 ≤ i.failedAttempts
  post := fun i o => o.restored = true ↔
    (i.failedAttempts + 1 ≤ 24 ∧
     o.systemState = i.systemState)

example : Spec.pre { failedAttempts := 10, systemState := "backup" } ∧
          Spec.post { failedAttempts := 10, systemState := "backup" }
                    { restored := true, systemState := "backup" } := by
  unfold Spec; decide
