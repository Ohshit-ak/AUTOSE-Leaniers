-- 5.1/R3: The system shall be able to retrieve 200 products per second.
-- checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  perSecond : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.perSecond ≥ 200

example : Spec.pre { } ∧ Spec.post { } { perSecond := 201 } := by
  unfold Spec; decide
