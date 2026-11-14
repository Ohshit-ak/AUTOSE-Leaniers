import ContractForge
open ContractForge

-- 3.11.1/S2: This can be done by selecting view/edit entry.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  entryId : Nat
  deriving DecidableEq, Repr

structure Output where
  description : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.entryId ≠ 0
  post := fun i o => o.description = "This can be done by selecting view/edit entry."

example : Spec.pre { entryId := 1 } ∧ Spec.post { entryId := 1 } { description := "This can be done by selecting view/edit entry." } := by
  unfold Spec; decide
