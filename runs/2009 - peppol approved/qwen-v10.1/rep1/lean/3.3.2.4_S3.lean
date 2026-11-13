import ContractForge
open ContractForge

-- 3.3.2.4/S3: If an economic operator decides to participate in a particular procurement procedure he can directly retrieve the relevant criteria by using the information published in the contract notice.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  criteria : List String
  deriving DecidableEq, Repr

structure Output where
  relevant : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.criteria ≠ []
  post := fun i o => o.relevant = i.criteria

example : Spec.pre { criteria := ["technical", "financial"] } ∧
          Spec.post { criteria := ["technical", "financial"] }
                    { relevant := ["technical", "financial"] } := by
  unfold Spec; decide
