import ContractForge
open ContractForge

-- 5.5/R5: The system shall validate email address existence.
-- compiles: True · rejects_bad_example: None · checked: True

structure Email where
  address : String
  deriving DecidableEq, Repr

structure Input where
  email : Email
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email.address ≠ ""
  post := fun i o => o.exists_ ↔
    (i.email.address.toList.all Char.isLower = true ∧
     i.email.address.contains '@' ∧
     i.email.address.contains '.')

example : Spec.pre { email := { address := "test@example.com" } } ∧ Spec.post { email := { address := "test@example.com" } } { exists_ := false } := by
  unfold Spec; decide
