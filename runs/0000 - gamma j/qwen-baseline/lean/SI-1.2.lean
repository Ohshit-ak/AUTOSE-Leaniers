-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.
-- checked: False

structure Item where
  name : String
  quantity : Nat

structure Input where
  items : List Item

structure Output where
  received : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.items.forall (fun item => item.quantity > 0)
  post := fun i o => o.received = true ↔ i.items.forall (fun item => item.quantity > 0)

example : Spec.pre ⟨[]⟩ ∧ Spec.post ⟨[]⟩ ⟨true⟩ := by
  simp [Spec]
