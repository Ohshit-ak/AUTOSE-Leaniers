import ContractForge
open ContractForge

-- DD-password: Password of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  raw : String
  min_length : Nat := 4
  max_length : Nat := 10
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.raw.length ≥ i.min_length ∧ i.raw.length ≤ i.max_length
  post := fun i o => (o.valid = true ↔
    i.raw.length ≥ i.min_length ∧ i.raw.length ≤ i.max_length ∧
    i.raw.toList.all (·.isAlphanum) = true) ∧
    (o.valid = false ↔
    i.raw.length < i.min_length)

example : Spec.pre { raw := "pass12", min_length := 4, max_length := 10 } ∧ Spec.post { raw := "pass12", min_length := 4, max_length := 10 } { valid := true } := by
  unfold Spec; decide
