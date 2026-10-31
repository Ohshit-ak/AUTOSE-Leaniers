-- DD-tracking-no: Number to track the order; 20 characters alphanumeric
-- checked: False

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 20 ∧ i.raw.toList.all (·.isAlphanum = true))

example : Spec.pre { raw := "A1B2C3D4E5F6G7H8I9J0K1L2" } ∧
          Spec.post { raw := "A1B2C3D4E5F6G7H8I9J0K1L2" }
                     { valid := true } := by
  unfold Spec; decide
