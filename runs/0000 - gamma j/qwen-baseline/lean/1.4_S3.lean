-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- checked: True

structure Input where
  ownerCode : String
  expansionAmount : Nat

structure Output where
  success : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.ownerCode ≠ "" ∧ i.expansionAmount > 0
  post := fun i o => o.success = true ↔ i.expansionAmount > 0

example : Spec.pre ⟨"uniqueCode", 5⟩ ∧ Spec.post ⟨"uniqueCode", 5⟩ ⟨true⟩ := by
  simp [Spec]
