import ContractForge
open ContractForge

-- 2.6.3/I6: maintenance of operations tables (such as filter lists) which can become part of an observation's permanent record
-- compiles: True · rejects_bad_example: None · checked: True

structure Operation where
  id     : Nat
  filter : List String
  deriving DecidableEq, Repr

structure Input where
  ops : List Operation
  deriving DecidableEq, Repr

structure Output where
  ops : List Operation
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.ops.Nodup
  post := fun i o => o.ops = i.ops ∧
                     (∀ op ∈ o.ops, op.filter.Nodup)

example : Spec.pre { ops := [{ id := 1, filter := ["a", "b"] },
                             { id := 2, filter := ["c"] }] } ∧
          Spec.post { ops := [{ id := 1, filter := ["a", "b"] },
                               { id := 2, filter := ["c"] }] }
                    { ops := [{ id := 1, filter := ["a", "b"] },
                              { id := 2, filter := ["c"] }] } := by
  unfold Spec; decide
