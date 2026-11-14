import ContractForge
open ContractForge

-- 3.2.5/S3: Reconfiguration procedures must exist, to change the observing environment.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  config : String
  changes : List String
  deriving DecidableEq, Repr

structure Output where
  config : String
  applied : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.config ≠ "" ∧ i.changes ≠ []
  post := fun i o => o.applied = true ↔
    (∀ c ∈ i.changes, c = i.config) ∧
    o.config = i.config ∧
    o.applied = (i.changes.length > 0)

example : Spec.pre { config := "env1", changes := ["env1"] } ∧
          Spec.post { config := "env1", changes := ["env1"] }
                    { applied := true, config := "env1" } := by
  unfold Spec; decide
