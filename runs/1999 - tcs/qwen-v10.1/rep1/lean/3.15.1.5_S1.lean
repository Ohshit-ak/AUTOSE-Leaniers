import ContractForge
open ContractForge

-- 3.15.1.5/S1: The TCS shall be configurable for sea, ground, as well as air transport in 2 hours or less. [SSS525] The TCS system shall be capable of being de-configured from sea, ground, as well as air transport and ground-mobile in 2 hours or less. [SSS526]
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  transportMode : String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  transportMode : String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.transportMode ∈ ["sea", "ground", "air"]
  post := fun i o => o.transportMode = i.transportMode ∧
                     o.elapsedMicros ≤ 7200000000

example : Spec.pre { transportMode := "sea", elapsedMicros := 0 } ∧
          Spec.post { transportMode := "sea", elapsedMicros := 7199999999 }
                    { transportMode := "sea", elapsedMicros := 7199999999 } := by
  unfold Spec; decide
