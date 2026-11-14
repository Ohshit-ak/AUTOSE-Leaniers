import ContractForge
open ContractForge

-- 5.5/R5: The system shall validate email address existence.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  email : String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ ""
  post := fun i o => o.exists_ = true ↔ i.email.toList.all Char.isLower = true ∧
                     i.email.contains '@' ∧
                     i.email.contains '.' ∧
                     i.email.length ≥ 6

example : Spec.pre { email := "test@example.com" } ∧ Spec.post { email := "test@example.com" } { exists_ := false } := by
  unfold Spec; decide
