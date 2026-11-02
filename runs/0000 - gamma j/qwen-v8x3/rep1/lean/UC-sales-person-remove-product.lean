import ContractForge
open ContractForge

-- UC-sales-person-remove-product: Remove Product: Remove a product from the system.
-- compiles: True · rejects_bad_example: True · checked: True

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  nameToRemove : String
  deriving DecidableEq, Repr

structure Output where
  products : List Product
  removed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.nameToRemove ≠ ""
  post := fun i o => o.removed = true ∧
                     o.products = i.products.filter (fun p => p.name ≠ i.nameToRemove)

example : Spec.pre { products := [{ name := "Laptop", price := 1000 },
                                   { name := "Mouse", price := 50 }],
                     nameToRemove := "Laptop" } ∧
          Spec.post { products := [{ name := "Laptop", price := 1000 },
                                   { name := "Mouse", price := 50 }],
                      nameToRemove := "Laptop" }
                    { products := [{ name := "Mouse", price := 50 }],
                      removed := true } := by
  unfold Spec; decide
