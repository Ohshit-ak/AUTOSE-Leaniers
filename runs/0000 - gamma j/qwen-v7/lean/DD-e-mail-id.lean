import ContractForge
open ContractForge

-- DD-e-mail-id: E-mail address of the customer who is using the Web order system; 50 characters alphanumeric
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    i.raw.length = 50 ∧
    i.raw.toList.all Char.isAlphanum = true

example : Spec.pre { raw := "aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890" } ∧ Spec.post { raw := "aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890" } { valid := false } := by
  unfold Spec; decide
