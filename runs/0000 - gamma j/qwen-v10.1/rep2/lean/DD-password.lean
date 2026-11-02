import ContractForge
open ContractForge

-- DD-password: Password of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  raw : String
  min_length : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.min_length ≤ i.raw.length
  post := fun i o => (o.valid = true ↔
    (4 ≤ i.raw.length ∧ i.raw.length ≤ 10 ∧
     i.raw.toList.all Char.isAlphanum = true)) ∧
    (o.valid = false ↔ i.raw.length < 4)

example : Spec.pre { raw := "pass12", min_length := 4 } ∧ Spec.post { raw := "pass12", min_length := 4 } { valid := true } := by
  unfold Spec; decide
