import ContractForge
open ContractForge

-- 3.4.3/I12: On-line version control must be implemented. That is, the version control system must be available to recover/restore versions at all times.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  version : Nat
  versionHistory : List Nat
  deriving DecidableEq, Repr

structure Output where
  version : Nat
  versionHistory : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.versionHistory.Nodup
  post := fun i o => o.version = i.version ∧
                     o.versionHistory = i.versionHistory ∧
                     (o.version = i.version → o.versionHistory = i.versionHistory)

example : Spec.pre { version := 3, versionHistory := [1, 2, 3] } ∧
          Spec.post { version := 3, versionHistory := [1, 2, 3] }
                    { version := 3, versionHistory := [1, 2, 3] } := by
  unfold Spec; decide
