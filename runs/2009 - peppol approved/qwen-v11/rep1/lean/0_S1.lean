import ContractForge
open ContractForge

-- 0/S1: This preface provides a short overview about the comments received from the EC and other sources and how these comments and remarks will be taken into consideration in future/ongoing work.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  comments : List String
  deriving DecidableEq, Repr

structure Output where
  report : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.comments.Nodup
  post := fun i o => o.report = "This preface provides a short overview about the comments received from the EC and other sources and how these comments and remarks will be taken into consideration in future/ongoing work." ∧
                     (i.comments.all (fun c => c ≠ ""))

example : Spec.pre { comments := ["EC comments", "Other source comments"] } ∧
          Spec.post { comments := ["EC comments", "Other source comments"] }
                    { report := "This preface provides a short overview about the comments received from the EC and other sources and how these comments and remarks will be taken into consideration in future/ongoing work." } := by
  set_option maxRecDepth 1000 in -- Increase recursion depth limit
  unfold Spec; decide
