-- 3.2.3/S2: The inventory management will allow for administrators to update the categories, the products placed in categories, and the specific product details.
-- checked: True

structure Input where
  category   : String
  products   : List String
  details    : String
  deriving DecidableEq, Repr

structure Output where
  updated    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.category ≠ "" ∧ i.products.Nodup ∧ i.details ≠ ""
  post := fun i o => o.updated = true ∧
                     (i.products = i.products.filter (fun p => p ≠ i.category)) ∧
                     (i.details = i.details)

example : Spec.pre { category := "Electronics", products := ["TV", "Laptop"], details := "Brand New" } ∧
          Spec.post { category := "Electronics", products := ["TV", "Laptop"], details := "Brand New" }
                     { updated := true } := by
  unfold Spec; decide
