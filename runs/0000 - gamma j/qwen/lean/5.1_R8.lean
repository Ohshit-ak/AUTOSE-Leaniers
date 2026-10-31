-- 5.1/R8: The system shall be able to acquire shipping charges in less than 2 seconds.
-- checked: True

structure Input where
  weight : Nat
  distance : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  fee : Nat
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.accepted = true ∧
                     (o.fee = 500 * i.weight + 100 * i.distance) ∧
                     o.elapsedMicros < 2000000

example : Spec.pre { weight := 1, distance := 50 } ∧ Spec.post { weight := 1, distance := 50 } { accepted := true, fee := 5500, elapsedMicros := 1999999 } := by
  unfold Spec; decide
