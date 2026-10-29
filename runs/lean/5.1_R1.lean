-- 5.1/R1: Upon the USB being plugged in the system shall be able to be deployed and operational in less than 1 minute.
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure Output where
  elapsedMicros : Nat

def Spec : Contract Input Output where
  pre := fun _ => true
  post := fun _ o => o.elapsedMicros < 60000000

example : Spec Input (Output.mk 50000000) := by decide
example : Spec Input (Output.mk 60000001) := by decide
