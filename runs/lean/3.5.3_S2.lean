-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- checked: None

structure Product where
  name : String
  price : Nat
  category : String

structure SearchCriteria where
  category : Option String
  minPrice : Option Nat

structure SearchResult where
  products : List Product

def Spec : Contract SearchCriteria SearchResult where
  pre criteria := true
  post criteria results := 
    results.products.forall (fun p => 
      match criteria.category with
      | some c => p.category = c
      | none   => true
      <-
    ) ∧
    results.products.forall (fun p => 
      match criteria.minPrice with
      | some min => p.price ≥ min
      | none     => true
      <-
    )

example : Spec (SearchCriteria.mk (some "Electronics") (some 100)) (SearchResult.mk [Product.mk "Laptop" 500 "Electronics"])
  := by
  simp [Spec.post]
  split
  · trivial
  · trivial
