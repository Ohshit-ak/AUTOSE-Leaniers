-- 1.4/S2: The initial inventory will be 100 items.
-- checked: None

structure Contract (α : Type) where
  pre  : α → Prop
  post : α → α → Prop

def Spec : Contract Nat Nat :=
  { pre := fun n => n = 100,
    post := fun n1 n2 => n2 = 100 }

example : Spec.pre 100 := by refl
example : Spec.post 100 100 := by refl
