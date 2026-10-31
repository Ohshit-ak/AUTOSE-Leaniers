-- DD-item-id: ID that uniquely identified the selected item; a 7-digit system generated alphanumeric character
-- checked: False

structure Input where
  item_id : String

structure ValidItemID where
  id : String
  exact_length : id.length = 7
  charset : ∀ c ∈ id, c.isAlphaNumeric

def Spec : Contract Input ValidItemID where
  pre  := fun i => i.item_id.length = 7 ∧ ∀ c, c.isAlphaNumeric → i.item_id.contains c
  post := fun i v => v.id = i.item_id ∧ v.exact_length ∧ v.charset

example : Spec.pre ⟨"ABC1234"⟩ ∧ Spec.post ⟨"ABC1234"⟩ ⟨"ABC1234", 7, fun c => c.isAlphaNumeric⟩ := by
  simp [Spec]
