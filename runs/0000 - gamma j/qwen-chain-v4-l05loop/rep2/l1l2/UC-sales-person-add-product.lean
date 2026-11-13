import ContractForge
open ContractForge

-- UC-sales-person-add-product: Add Product: Add a product to the system.

-- L0 spec

structure Product where
  name : String
  price : Nat
  description : String
  deriving DecidableEq, Repr

structure Input where
  name : String
  price : Nat
  description : String
  deriving DecidableEq, Repr

structure Output where
  name : String
  price : Nat
  description : String
  productPageCreated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.price > 0
  post := fun i o => o.name = i.name ∧
                     o.price = i.price ∧
                     o.description = i.description ∧
                     o.productPageCreated = true

example : Spec.pre { name := "Laptop", price := 1000, description := "A high-end laptop" } ∧
          Spec.post { name := "Laptop", price := 1000, description := "A high-end laptop" }
                    { name := "Laptop", price := 1000, description := "A high-end laptop", productPageCreated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { name := x.name, price := x.price, description := x.description, productPageCreated := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
