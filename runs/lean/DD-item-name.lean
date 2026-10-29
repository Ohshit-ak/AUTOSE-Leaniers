-- DD-item-name: Name of the selected item; maximum 50 character alphabetic string
-- checked: None

structure Contract (α : Type) where
  pre  : α → Prop
  post : α → Prop

def ItemName : Type := String
def validItemName (s : ItemName) : Prop := 
  s.length ≤ 50 ∧ s.all (· ∈ 'a'..'z')

def Spec : Contract ItemName Bool where
  pre s := validItemName s
  post s b := b

example : Spec "abc" true := by
  simp [Spec.post, validItemName]

example : ¬ Spec "a" true := by
  simp [Spec.post, validItemName]
