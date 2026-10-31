-- DD-e-mail-id: E-mail address of the customer who is using the Web order system; 50 characters alphanumeric
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
    (i.raw.length = 50) ∧
    i.raw.toList.all (·.isAlphanum) = true

example : Spec.pre { raw := "A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6" } ∧
          Spec.post { raw := "A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0U1V2W3X4Y5Z6" }
                    { valid := true } := by
  unfold Spec
  split
  -- Prove the length condition
  constructor
  exact i.raw.length = 50
  -- Prove the character set condition
  constructor
  exact i.raw.toList.all (·.isAlphanum) = true
