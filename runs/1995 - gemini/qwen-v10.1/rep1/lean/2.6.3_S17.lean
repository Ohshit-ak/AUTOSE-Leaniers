import ContractForge
open ContractForge

-- 2.6.3/S17: However it must be recognized that:
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  amount  : Nat
  limit   : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  fee      : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.limit
  post := fun i o => (o.accepted = true ↔ i.amount ≤ i.limit) ∧
                     (o.accepted = false → o.fee = 0)

example : Spec.pre { amount := 5, limit := 10 } ∧
          Spec.post { amount := 5, limit := 10 } { accepted := true, fee := 1 } := by
  unfold Spec; decide
