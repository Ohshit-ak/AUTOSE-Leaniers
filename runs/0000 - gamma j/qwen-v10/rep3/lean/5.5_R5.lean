import ContractForge
open ContractForge

-- 5.5/R5: The system shall validate email address existence.
-- compiles: True · rejects_bad_example: True · checked: True

structure Email where
  address : String
  deriving DecidableEq, Repr

structure Input where
  address : String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.address ≠ ""
  post := fun i o => o.exists_ = true ↔
    i.address.toList.all Char.isAlphanum = true ∧
    i.address.contains '@' ∧
    i.address.contains '.' ∧
    i.address.length ≥ 6

example : Spec.pre { address := "test@example.com" } ∧ Spec.post { address := "test@example.com" } { exists_ := false } := by
  unfold Spec; decide
