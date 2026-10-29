-- 5.1/R4: The system shall be able to add product to shopping cart in less than 2ms.
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure Output where
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre := fun _ => True
  post := fun _ o => o.elapsedMicros < 2000

example : Spec Input (Output.mk 1999) := by decide
example : Spec Input (Output.mk 2000) := by decide
example : ¬ Spec Input (Output.mk 2001) := by decide
