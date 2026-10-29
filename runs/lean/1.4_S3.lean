-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.
-- checked: None

structure ProductCode where
  code : String

structure Inventory where
  products : List (String × ProductCode)

structure Purchase where
  codes : List ProductCode

structure Owner where
  purchases : List Purchase

structure Contract (α : Type) where
  pre : α → Prop
  post : α → α → Prop

def Spec : Contract Owner Inventory where
  pre o := true
  post o o' := o.purchases = o'.purchases ∧ o'.products = o.products ++ (o.purchases.map (fun p => p.codes.map (fun c => c.code))).flatten

example : Spec (Owner.mk []) (Inventory.mk []) := by
  simp [Spec.post]
