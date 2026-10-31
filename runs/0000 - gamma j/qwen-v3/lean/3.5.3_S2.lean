-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- checked: True

structure Input where
  query : String
  deriving DecidableEq, Repr

structure Output where
  foundProducts : List String
  accepted      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.accepted = true ∧
                     o.foundProducts.Nodup ∧
                     o.foundProducts.all (fun p => i.query.length ≤ p.length) ∧
                     o.foundProducts.all (fun p => i.query.toList.all (· ∈ p.toList) = true)

example : Spec.pre { query := "camera" } ∧
          Spec.post { query := "camera" }
                     { foundProducts := ["digital camera", "camera lens"], accepted := true } := by
  unfold Spec; decide
