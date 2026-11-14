import ContractForge
open ContractForge

-- UC-sales-person-remove-product: Remove Product: Remove a product from the system.

-- L0 spec

structure Product where
  name   : String
  price  : Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  name     : String
  price    : Nat
  deriving DecidableEq, Repr

structure Output where
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.products.Nodup
  post := fun i o => o.products.length = i.products.length - 1 ∧
                     ∃ p ∈ i.products, p.name = i.name ∧ p.price = i.price ∧
                     ∀ p ∈ o.products, p.name ≠ i.name ∨ p.price ≠ i.price

example : Spec.pre { products := [{ name := "Laptop", price := 1000 },
                                   { name := "Mouse", price := 50 }],
                     name := "Laptop", price := 1000 } ∧
          Spec.post { products := [{ name := "Laptop", price := 1000 },
                                   { name := "Mouse", price := 50 }],
                      name := "Laptop", price := 1000 }
                    { products := [{ name := "Mouse", price := 50 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { products := x.products.filter (fun p => p.name ≠ x.name ∨ p.price ≠ x.price) }
