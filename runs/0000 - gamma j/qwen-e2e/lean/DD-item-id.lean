import ContractForge
open ContractForge

-- DD-item-id: ID that uniquely identified the selected item; a 7-digit system generated alphanumeric character
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 7) ∧
    i.raw.toList.all (·.isAlphanum) = true

example : Spec.pre { raw := "A1B2C3D" } ∧
          Spec.post { raw := "A1B2C3D" } { valid := true } := by
  unfold Spec; decide
