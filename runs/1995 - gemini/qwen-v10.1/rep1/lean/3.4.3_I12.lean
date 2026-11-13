import ContractForge
open ContractForge

-- 3.4.3/I12: On-line version control must be implemented. That is, the version control system must be available to recover/restore versions at all times.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  versions : List String
  deriving DecidableEq, Repr

structure Output where
  versions : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.versions = i.versions

example : Spec.pre { versions := ["v1", "v2", "v3"] } ∧
          Spec.post { versions := ["v1", "v2", "v3"] } { versions := ["v1", "v2", "v3"] } := by
  unfold Spec; decide
