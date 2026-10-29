-- DD-quantity: the number of units of each selected item that the customer is ordering; default = 1; maximum = quantity presently in inventory
-- checked: None

structure Contract (α : Type) where
  pre  : α → Prop
  post : α → Prop

def Quantity (q : Nat) : Prop :=
  1 ≤ q ∧ q ≤ inventoryQuantity

def inventoryQuantity : Nat := 100

example : Contract Nat (Quantity Nat) :=
{ pre := Quantity,
  post := fun q => Quantity q }
