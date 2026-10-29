-- DD-item-id: ID that uniquely identified the selected item; a 7-digit system generated alphanumeric character
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

def ItemID : Type := String
def validItemID (id : ItemID) : Prop :=
  id.length = 7 ∧ id.forall (λ c, c.isLower ∨ c.isUpper ∨ c.isDigit)

def Spec : Contract ItemID Bool :=
  { pre := λ id, id.length = 7 ∧ id.forall (λ c, c.isLower ∨ c.isUpper ∨ c.isDigit),
    post := λ id valid, validItemID id }

example : Spec.pre "ABC1234" := by
  simp

example : ¬Spec.pre "ABC12345" := by
  simp

example : Spec.post "ABC1234" true := by
  simp

example : ¬Spec.post "ABC12345" true := by
  simp
