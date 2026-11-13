import ContractForge
open ContractForge

-- 3.2.1.3/S3: It shall be possible to update all non-protected parameter values, i.e. those not used by operations at observing level.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  parameters : List String
  protected  : List String
  deriving DecidableEq, Repr

structure Output where
  updatedParameters : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.parameters.length > 0 ∧ i.protected.length < i.parameters.length
  post := fun i o => o.updatedParameters = i.parameters \ i.protected

example : Spec.pre { parameters := ["p1", "p2", "p3"], protected := ["p2"] } ∧
          Spec.post { parameters := ["p1", "p2", "p3"], protected := ["p2"] }
                    { updatedParameters := ["p1", "p3"] } := by
  unfold Spec; decide
