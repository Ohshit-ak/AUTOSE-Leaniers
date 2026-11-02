import ContractForge
open ContractForge

-- UC-sales-person-remove-product: Remove Product: Remove a product from the system.
-- compiles: True · rejects_bad_example: None · checked: False

structure Product where
  name   : String
  price  : Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  name     : String
  deriving DecidableEq, Repr

structure Output where
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ ""
  post := fun i o => ∃ p ∈ i.products, p.name = i.name ∧
                     (o.products = i.products.filter (fun p' => p'.name ≠ i.name) ↔
                      o.products.length = i.products.length - 1)

example : Spec.pre { products := [{ name := "apple", price := 100 },
                                  { name := "banana", price := 200 }],
                     name := "apple" } ∧
          Spec.post { products := [{ name := "apple", price := 100 },
                                   { name := "banana", price := 200 }],
                      name := "apple" }
                    { products := [{ name := "banana", price := 200 }] } := by
  unfold Spec; decide
