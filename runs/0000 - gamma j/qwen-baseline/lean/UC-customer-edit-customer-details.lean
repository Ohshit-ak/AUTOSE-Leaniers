-- UC-customer-edit-customer-details: Edit Customer Details: Edit the customer account details.
-- checked: False

structure Input where
  customerID : Nat
  changes    : List (Nat × String)  -- (fieldID, newValue)

structure Output where
  success : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.customerID ≠ 0
  post := fun i o => o.success = true ↔ i.changes ≠ []

example : Spec.pre ⟨123, []⟩ ∧ Spec.post ⟨123, []⟩ ⟨true⟩ := by
  simp [Spec]
