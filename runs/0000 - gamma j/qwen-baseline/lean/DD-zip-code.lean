-- DD-zip-code: The postal code of the above address; 5 digit numeric string
-- checked: False

structure Input where
  raw_value : String

structure Output where
  valid : Bool

def isNumeric (c : Char) : Prop := c = '0' ∨ c = '1' ∨ c = '2' ∨ c = '3' ∨ c = '4' ∨ c = '5' ∨ c = '6' ∨ c = '7' ∨ c = '8' ∨ c = '9'

def Spec : Contract Input Output where
  pre  := fun i => i.raw_value.length = 5 ∧ i.raw_value.all isNumeric
  post := fun i o => o.valid = true ↔ Spec.pre i

example : Spec.pre ⟨"12345"⟩ ∧ Spec.post ⟨"12345"⟩ ⟨true⟩ := by
  simp [Spec]
