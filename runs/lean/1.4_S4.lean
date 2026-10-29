-- 1.4/S4: The minimum total inventory will be 20,000 items.
-- checked: None

structure Contract (items : Type) where
  pre : items → Prop
  post : items → Prop

def Spec : Contract Nat :=
{ pre := λ n, n ≥ 20000,
  post := λ n, n ≥ 20000,
  }

example : Spec.pre 20000 := by
  exact le_refl 20000

example : Spec.post 20000 := by
  exact le_refl 20000
