import ContractForge
open ContractForge

-- 4/ease-of-use/R7: The System must allow persistent defaults for data entry where desirable. These defaults should include: user-definable values; values same as previous item; values derived from context, e.g. date, file reference, user identifier;
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  defaults : List String
  deriving DecidableEq, Repr

structure Output where
  defaults : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.defaults ≠ []
  post := fun i o => o.defaults = i.defaults

example : Spec.pre { defaults := ["user123", "2023-10-01", "file.txt"] } ∧
          Spec.post { defaults := ["user123", "2023-10-01", "file.txt"] }
                    { defaults := ["user123", "2023-10-01", "file.txt"] } := by
  unfold Spec; decide
