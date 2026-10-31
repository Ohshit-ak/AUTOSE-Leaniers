import ContractForge
open ContractForge

-- DD-item-name: Name of the selected item; maximum 50 character alphabetic string
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length ≤ 50) ∧
    i.raw.all (·.isAlpha) = true

example : Spec.pre { raw := "itemname" } ∧
          Spec.post { raw := "itemname" }
                    { valid := true } := by
  unfold Spec; decide
