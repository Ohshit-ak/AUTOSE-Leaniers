import ContractForge
open ContractForge

-- 0/S6: First of all, D2.1 will be updated and improved in the following respects:
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  items : List String
  limit : Nat
  deriving DecidableEq, Repr

structure Output where
  processed : List String
  count : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items.length > 0 ∧ 0 < i.limit
  post := fun i o => o.processed.length = i.items.length ∧
                     o.count = i.items.length ∧
                     ∀ it ∈ o.processed, it ∈ i.items ∧
                     o.processed.length ≤ i.limit

example : Spec.pre { items := ["a", "b", "c"], limit := 3 } ∧
          Spec.post { items := ["a", "b", "c"], limit := 3 }
                    { processed := ["a", "b", "c"], count := 3 } := by
  unfold Spec; decide
