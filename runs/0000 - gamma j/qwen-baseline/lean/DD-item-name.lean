-- DD-item-name: Name of the selected item; maximum 50 character alphabetic string
-- checked: False

structure Input where
  item_name : String

def is_valid_name (s : String) : Prop :=
  s.length ≤ 50 ∧ s.forall (fun c => c.isAlpha)

def Spec : Contract Input Bool where
  pre  := fun i => is_valid_name i.item_name
  post := fun i _ => is_valid_name i.item_name

example : Spec.pre ⟨"ShortName"⟩ ∧ Spec.post ⟨"ShortName"⟩ true := by
  simp [Spec]
