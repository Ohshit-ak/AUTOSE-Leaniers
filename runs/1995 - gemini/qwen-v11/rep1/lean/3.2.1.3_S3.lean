import ContractForge
open ContractForge

-- 3.2.1.3/S3: It shall be possible to update all non-protected parameter values, i.e. those not used by operations at observing level.
-- compiles: False · rejects_bad_example: None · checked: False

structure Parameter where
  value : Nat
  protected : Bool
  deriving DecidableEq, Repr

structure Input where
  parameters : List Parameter
  deriving DecidableEq, Repr

structure Output where
  parameters : List Parameter
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.parameters.Nodup
  post := fun i o => o.parameters = i.parameters ∧
                     ∀ p ∈ o.parameters, p.protected = i.p.protected

example : Spec.pre { parameters := [{ value := 10, protected := false },
                                     { value := 20, protected := true }] } ∧
          Spec.post { parameters := [{ value := 10, protected := false },
                                     { value := 20, protected := true }] }
                    { parameters := [{ value := 15, protected := false },
                                     { value := 25, protected := true }] } := by
  unfold Spec; decide
