import ContractForge
open ContractForge

-- 3.11.4/I3: TPM denotes Total Preventative Maintenance
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  TPM : Nat
  failures : Nat
  deriving DecidableEq, Repr

structure Output where
  TPM : Nat
  failures : Nat
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.TPM
  post := fun i o => (o.success = true ↔ i.failures = 0) ∧
                     (o.success = false → i.failures > 0) ∧
                     o.TPM = i.TPM ∧
                     o.failures = i.failures

example : Spec.pre { TPM := 100, failures := 0 } ∧
          Spec.post { TPM := 100, failures := 0 }
                    { TPM := 100, failures := 0, success := true } := by
  unfold Spec; decide
