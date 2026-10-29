-- DD-tracking-no: Number to track the order; 20 characters alphanumeric
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

def TrackingNo : Type := String

def isTrackingNoValid (tn : TrackingNo) : Prop :=
  tn.length = 20 ∧ ∀ i, i < tn.length → tn[i] ∈ ('a'..'z') ∪ ('A'..'Z') ∪ ('0'..'9')

def Spec : Contract TrackingNo Bool :=
  { pre := λ tn, tn.length ≤ 20,
    post := λ tn valid, isTrackingNoValid tn }

example : Spec.pre "ABC1234567890123456" := by
  simp

example : Spec.post "ABC1234567890123456" true := by
  simp

example : ¬ Spec.post "ABC12345678901234567" true := by
  simp
