-- UC-administrator-change-user-properties: Change User Properties: Alter properties such as passwords and privileges of the user.
-- checked: True

structure Input where
  user_id : Nat
  new_password : String
  new_privileges : Nat

structure Output where
  altered : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.new_password ≠ "" ∧ i.new_privileges ≥ 0
  post := fun i o => o.altered = true

example : Spec.pre ⟨1, "newPass123", 10⟩ ∧ Spec.post ⟨1, "newPass123", 10⟩ ⟨true⟩ := by
  simp [Spec]
