import ContractForge
open ContractForge

-- 5.1/R9: The system shall be able to restore 1000 records per second.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  perSecond : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.perSecond ≥ 1000

example : Spec.pre { } ∧ Spec.post { } { perSecond := 1001 } := by
  unfold Spec; decide
