-- DD-order-no: Unique confirmation number of the order to the customer; 9 characters alphanumeric
-- checked: True

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 9) ∧
    i.raw.toList.all (·.isAlphanum) = true

example : Spec.pre { raw := "A1B2C3D4E" } ∧
          Spec.post { raw := "A1B2C3D4E" } { valid := true } := by
  unfold Spec; decide
