import ContractForge
open ContractForge

-- 3.3.3/S1: Customers will also be able to add products into the shopping cart.

-- L0 spec

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  cart : List Product
  productToAdd : Product
  deriving DecidableEq, Repr

structure Output where
  cart : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.cart.length = i.cart.length + 1 ∧
                     o.cart.contains i.productToAdd

example : Spec.pre { cart := [], productToAdd := { name := "Laptop", price := 1000 } } ∧
          Spec.post { cart := [], productToAdd := { name := "Laptop", price := 1000 } }
                    { cart := [{ name := "Laptop", price := 1000 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { cart := x.cart ++ [x.productToAdd] }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
