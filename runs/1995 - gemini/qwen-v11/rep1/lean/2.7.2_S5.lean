import ContractForge
open ContractForge

-- 2.7.2/S5: The system design, if it does not include a scheduler, should specifically allow for its future implementation.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  queue : List Nat
  deriving DecidableEq, Repr

structure Output where
  processed : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.processed.length = i.queue.length ∧
                     (∀ n ∈ i.queue, ∃ p ∈ o.processed, p = n) ∧
                     o.processed.Nodup

example : Spec.pre { queue := [1, 2, 3] } ∧
          Spec.post { queue := [1, 2, 3] }
                    { processed := [1, 2, 3] } := by
  unfold Spec; decide
