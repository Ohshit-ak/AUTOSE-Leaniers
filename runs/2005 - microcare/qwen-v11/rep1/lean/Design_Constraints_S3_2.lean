import ContractForge
open ContractForge

-- Design Constraints/S3#2: On capture of any duplicate name the system will give a warning message to have the duplicate name or to change the name.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  names : List String
  deriving DecidableEq, Repr

structure Output where
  warnings : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.names.Nodup
  post := fun i o => o.warnings.length ≤ i.names.length ∧
                     (∀ w ∈ o.warnings, ∃ n ∈ i.names, w = "Duplicate name: " ++ n)

example : Spec.pre { names := [] } ∧ Spec.post { names := [] } { warnings := [] } := by
  unfold Spec; decide
