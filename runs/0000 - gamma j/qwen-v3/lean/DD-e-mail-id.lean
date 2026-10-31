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
    (i.raw.toList.all Char.isAlphanum = true)

example : Spec.pre { raw := "aBc1234567890aBc1234567890aBc1234567890aBc123456" } ∧
          Spec.post { raw := "aBc1234567890aBc1234567890aBc1234567890aBc123456" }
                    { valid := true } := by
  unfold Spec; decide
