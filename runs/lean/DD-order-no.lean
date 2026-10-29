-- DD-order-no: Unique confirmation number of the order to the customer; 9 characters alphanumeric
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

def OrderNo : Type := String
def validOrderNo (s : OrderNo) : Prop :=
  s.length = 9 ∧ s.forall (λ c, c.isLower ∨ c.isUpper ∨ c.digit)

def Spec : Contract OrderNo Bool :=
  { pre := λ s, s.length = 9 ∧ s.forall (λ c, c.isLower ∨ c.isUpper ∨ c.digit),
    post := λ s valid, validOrderNo s → valid }

example : Spec.pre "AB1234567" :=
  by simp

example (s : OrderNo) (h : Spec.post s true) : validOrderNo s :=
  by simp [h]
