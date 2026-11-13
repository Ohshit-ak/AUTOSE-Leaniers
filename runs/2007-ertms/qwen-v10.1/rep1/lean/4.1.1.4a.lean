import ContractForge
open ContractForge

-- 4.1.1.4a: The trackside shall be able to send information for the calculation of speed profiles.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  speed : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  profile : List Nat
  sum : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.speed ≤ 1000
  post := fun i o => o.valid = true ∧
                     o.profile.length = 10 ∧
                     o.profile.all (fun p => 0 ≤ p ∧ p ≤ 100) ∧
                     o.profile.sum = i.speed

example : Spec.pre { speed := 500 } ∧
          Spec.post { speed := 500 }
                    { valid := true, profile := [50, 50, 50, 50, 50, 50, 50, 50, 50, 50], sum := 500 } := by
  unfold Spec; decide
