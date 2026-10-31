-- 5.1/R8: The system shall be able to acquire shipping charges in less than 2 seconds.
-- checked: False

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
  pre  := fun i => true
  post := fun i o => o.accepted = true ∧
                     (o.elapsedMicros < 2000000) ∧
                     (o.fee = 10 * i.weight + 5 * i.distance)

example : Spec.pre { weight := 5, distance := 10 } ∧
          Spec.post { weight := 5, distance := 10 }
                    { accepted := true, fee := 70, elapsedMicros := 1500000 } := by
  unfold Spec; decide
