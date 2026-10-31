import ContractForge
open ContractForge

-- DD-tracking-no: Number to track the order; 20 characters alphanumeric
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
    (i.raw.length = 20 ∧
     i.raw.toList.all Char.isAlphanum = true)

example : Spec.pre { raw := "A1B2C3D4E5F6G7H8I9J0" } ∧
          Spec.post { raw := "A1B2C3D4E5F6G7H8I9J0" }
                    { valid := true } := by
  unfold Spec; decide
