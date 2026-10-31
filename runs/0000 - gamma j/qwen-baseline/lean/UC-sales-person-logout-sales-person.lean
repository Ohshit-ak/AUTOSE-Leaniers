-- UC-sales-person-logout-sales-person: Logout Sales Person: Logout the Sales Person account on the system.
-- checked: False

structure Input where
  is_logged_in : Bool

structure Output where
  is_logged_out : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.is_logged_in
  post := fun i o => o.is_logged_out = true

example : Spec.pre ⟨true⟩ ∧ Spec.post ⟨true⟩ ⟨false⟩ := by
  simp [Spec]
