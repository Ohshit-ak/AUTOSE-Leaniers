import ContractForge
open ContractForge

-- DD-password: Password of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 10 ∧
     i.raw.toList.all Char.isAlphanum = true)

example : Spec.pre { raw := "pass12" } ∧
          Spec.post { raw := "pass12" }
                    { valid := true } := by
  unfold Spec; decide
