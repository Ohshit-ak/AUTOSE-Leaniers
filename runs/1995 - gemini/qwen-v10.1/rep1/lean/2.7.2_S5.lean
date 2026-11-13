import ContractForge
open ContractForge

-- 2.7.2/S5: The system design, if it does not include a scheduler, should specifically allow for its future implementation.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  queue : List Nat
  hasScheduler : Bool
  deriving DecidableEq, Repr

structure Output where
  processed : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.hasScheduler = false
  post := fun i o => if i.hasScheduler then
                       o.processed.length = i.queue.length ∧
                       (∀ n ∈ i.queue, ∃ p ∈ o.processed, p = n) ∧
                       o.processed.Nodup
                     else
                       o.processed.length = 0

example : Spec.pre { queue := [1, 2, 3], hasScheduler := false } ∧
          Spec.post { queue := [1, 2, 3], hasScheduler := false }
                    { processed := [] } := by
  unfold Spec; decide
