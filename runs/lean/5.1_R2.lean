-- 5.1/R2: The system shall be able to handle 1000 customers logged in concurrently at the same time.
-- checked: None

structure Customer := (id : Nat)

structure Contract (α : Type) where
  pre  : α → Prop
  post : α → Nat → Prop

structure Output := (concurrentUsers : Nat)

def Spec : Contract Unit (Output := Nat) :=
  { pre := fun _ => True,
    post := fun _ concurrentUsers =>
      concurrentUsers ≥ 1000 }

example : Spec.pre () ∧ Spec.post () 1001 := by
  constructor
  exact Iff.refl (Spec.pre ())
  simp [Spec.post]
