import ContractForge
open ContractForge

-- 3.5.3/S2: Customers will be able to search for products matching their search criteria.
-- compiles: True · rejects_bad_example: None · checked: False

structure Product where
  name : String
  category : String
  price : Nat
  deriving DecidableEq, Repr

structure SearchCriteria where
  name : Option String
  category : Option String
  minPrice : Option Nat
  maxPrice : Option Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  criteria : SearchCriteria
  deriving DecidableEq, Repr

structure Output where
  results : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.products.Nodup
  post := fun i o => o.results.all (fun p => 
    (i.criteria.name = none ∨ i.criteria.name.getD "" = p.name) ∧
    (i.criteria.category = none ∨ i.criteria.category.getD "" = p.category) ∧
    (i.criteria.minPrice = none ∨ p.price ≥ i.criteria.minPrice.getD 0) ∧
    (i.criteria.maxPrice = none ∨ p.price ≤ i.criteria.maxPrice.getD 10000))

example : Spec.pre { 
  products := [ { name := "Laptop", category := "Electronics", price := 500 },
                { name := "Keyboard", category := "Electronics", price := 100 },
                { name := "Mouse", category := "Electronics", price := 50 } ],
  criteria := { name := none, category := none, minPrice := some 50, maxPrice := some 300 }
} ∧
Spec.post { 
  products := [ { name := "Laptop", category := "Electronics", price := 500 },
                { name := "Keyboard", category := "Electronics", price := 100 },
                { name := "Mouse", category := "Electronics", price := 50 } ],
  criteria := { name := none, category := none, minPrice := some 50, maxPrice := some 300 }
}
{ results := [ { name := "Keyboard", category := "Electronics", price := 100 },
               { name := "Mouse", category := "Electronics", price := 50 } ] }
:= by
  unfold Spec; decide
