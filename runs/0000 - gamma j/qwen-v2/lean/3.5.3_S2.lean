-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- checked: False

structure Input where
  query : String
  deriving DecidableEq, Repr

structure Output where
  found  : Bool
  products : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.found = true ↔ i.query.length > 0 ∧
                     (o.products.Nodup ∧ o.products.all (fun p => i.query.toList.any (fun c => c == p)) = true)

example : Spec.pre { query := "camera" } ∧
          Spec.post { query := "camera" } { found := true, products := ["Canon Camera", "Nikon Camera"] } := by
  unfold Spec; decide
