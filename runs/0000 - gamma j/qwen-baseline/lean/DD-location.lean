-- DD-location: Place where the item is kept in the warehouse in the form of (aisle, column, shelf)
-- checked: False

structure Input where
  Location : String

structure Output where
  valid : Bool

def LocationValidity : String → Prop
| s => s.length = 3 ∧ s[0] ∈ 'A'..'Z' ∧ s[1] ∈ '1'..'9' ∧ s[2] ∈ 'A'..'Z'

def Spec : Contract Input Output where
  pre  := fun i => LocationValidity i.Location
  post := fun i o => o.valid = true ↔ LocationValidity i.Location

example : Spec.pre ⟨"A1Z"⟩ ∧ Spec.post ⟨"A1Z"⟩ ⟨true⟩ := by
  simp [Spec]
