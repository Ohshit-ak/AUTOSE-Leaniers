-- 1.4/S4: The minimum total inventory will be 20,000 items.
-- checked: True

structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items ≥ 20000
  post := fun i o => o.accepted = true

example : Spec.pre { items := 20000 } ∧ Spec.post { items := 20000 } { accepted := true } := by
  unfold Spec; decide
