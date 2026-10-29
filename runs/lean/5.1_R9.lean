-- 5.1/R9: The system shall be able to restore 1000 records per second.
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure Output where
  perSecond : Nat

def Spec : Contract Input Output where
  pre := fun _ => True
  post := fun _ o => o.perSecond ≥ 1000

example : Spec Input (Output.mk 1000) := by decide
example : Spec Input (Output.mk 1200) := by decide
example : ¬ Spec Input (Output.mk 999) := by decide
