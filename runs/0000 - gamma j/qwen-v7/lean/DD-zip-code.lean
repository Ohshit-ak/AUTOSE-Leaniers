import ContractForge
open ContractForge

-- DD-zip-code: The postal code of the above address; 5 digit numeric string
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
    (i.raw.length = 5 ∧ i.raw.toList.all Char.isDigit = true)

example : Spec.pre { raw := "12345" } ∧
          Spec.post { raw := "12345" }
                    { valid := true } := by
  unfold Spec; decide
