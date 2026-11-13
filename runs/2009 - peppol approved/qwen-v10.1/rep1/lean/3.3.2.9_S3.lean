import ContractForge
open ContractForge

-- 3.3.2.9/S3: Requirement Special legal regulations for evidences MUST be considered (e.g. for extract from the register of conviction).
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  evidence : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    i.evidence = "extract from the register of conviction" ∨
    i.evidence = "other special legal regulation"

example : Spec.pre { evidence := "extract from the register of conviction" } ∧
          Spec.post { evidence := "extract from the register of conviction" }
                    { valid := true } := by
  unfold Spec; decide
