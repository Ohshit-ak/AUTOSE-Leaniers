import ContractForge
open ContractForge

-- 11.3.3.3: 11.3.3.3 It shall be possible to deregister up to ten functional numbers to items of equipment physically connected to the Cab radio within 30 seconds. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  functionalNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  deregistered : Nat
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumbers.length ≤ 10
  post := fun i o => o.deregistered = i.functionalNumbers.length ∧
                      o.elapsedMicros ≤ 30000000

example : Spec.pre { functionalNumbers := ["1234", "5678", "9012", "3456", "7890", "1234", "5678", "9012", "3456", "7890"] } ∧
          Spec.post { functionalNumbers := ["1234", "5678", "9012", "3456", "7890", "1234", "5678", "9012", "3456", "7890"] }
                    { deregistered := 10, elapsedMicros := 2500000 } := by
  unfold Spec; decide
