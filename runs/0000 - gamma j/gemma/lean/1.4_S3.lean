-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- checked: True

structure Input where
  inventory : List Nat
  new_codes : List Nat

structure Output where
  updated_inventory : List Nat
  success : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.inventory.Pairwise (λ x y => x ≠ y) ∧ i.new_codes.Pairwise (λ x y => x ≠ y)
  post := fun i o =>
    (o.success = true ↔ (∀ x ∈ i.new_codes, x ∉ i.inventory)) ∧
    (o.success = true → o.updated_inventory.Perm (i.inventory ++ i.new_codes)) ∧
    (o.success = false → o.updated_inventory = i.inventory)

example : Spec.pre ⟨[1, 2], [3, 4]⟩ ∧ Spec.post ⟨[1, 2], [3, 4]⟩ ⟨[1, 2, 3, 4], true⟩ := by
  simp [Spec]
