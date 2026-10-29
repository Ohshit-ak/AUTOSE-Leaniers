-- 5.1/R6: The system shall be able to email customer and vendor in less than 1 second.
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure Output where
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre := fun _ => True
  post := fun _ o =>
    o.elapsedMicros < 1000000

example : Spec Input (Output.mk 500000) := by decide
example : Spec Input (Output.mk 1200000) := by decide
example : Spec Input (Output.mk 999999) := by decide
example : Spec Input (Output.mk 1000001) := by decide
