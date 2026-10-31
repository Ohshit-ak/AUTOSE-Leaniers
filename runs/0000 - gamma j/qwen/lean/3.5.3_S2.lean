-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- checked: True

structure Input where
  query : String
  deriving DecidableEq, Repr

structure Output where
  found  : List String
  count  : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query.length ≥ 3
  post := fun i o => o.count = o.found.length ∧
                     o.found.all (·.length > 0) ∧
                     o.found.all (fun s => i.query.toList.any (· ∈ s.toList) = true)

example : Spec.pre { query := "apple" } ∧
          Spec.post { query := "apple" } { found := ["apple", "pineapple"], count := 2 } := by
  unfold Spec; decide
