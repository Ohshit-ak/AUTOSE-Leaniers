import ContractForge
open ContractForge

-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.

-- L0 spec

structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Output where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0 ∧ i.rating > 0
  post := fun i o => o.name = i.name ∧
                     o.price = i.price ∧
                     o.stock = i.stock ∧
                     o.rating = i.rating

example : Spec.pre { name := "Laptop", price := 1000, stock := 50, rating := 4 } ∧
          Spec.post { name := "Laptop", price := 1000, stock := 50, rating := 4 }
                    { name := "Laptop", price := 1000, stock := 50, rating := 4 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { name := x.name, price := x.price, stock := x.stock, rating := x.rating }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
