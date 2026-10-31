-- UC-administrator-remove-user: Remove User: Remove a user from the system.
-- checked: False

structure Input where
  user_id : Nat

structure Output where
  confirmation : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.user_id ≠ 0
  post := fun i o => o.confirmation = true → i.user_id = 0

example : Spec.pre ⟨5⟩ ∧ Spec.post ⟨5⟩ ⟨true⟩ := by
  simp [Spec]
