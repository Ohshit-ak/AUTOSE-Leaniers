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
  post := fun i o => o.products = i.products.filter (fun p => p.name ≠ i.name ∧ p.price ≠ i.price)

example : Spec.pre { products := [{ name := "apple", price := 100 },
                                   { name := "banana", price := 200 }],
                     name := "apple", price := 100 } ∧
          Spec.post { products := [{ name := "apple", price := 100 },
                                    { name := "banana", price := 200 }],
                      name := "apple", price := 100 }
                    { products := [{ name := "banana", price := 200 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { products := x.products.filter (fun p => p.name ≠ x.name ∧ p.price ≠ x.price) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
