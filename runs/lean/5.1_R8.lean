-- 5.1/R8: The system shall be able to acquire shipping charges in less than 2 seconds.
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure Output where
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre := fun _ => True
  post := fun _ o => o.elapsedMicros < 2000000

example : Spec Input (Output.mk 1000000) := by decide
example : Spec Input (Output.mk 1999999) := by decide
example : Spec Input (Output.mk 2000001) := by decide
