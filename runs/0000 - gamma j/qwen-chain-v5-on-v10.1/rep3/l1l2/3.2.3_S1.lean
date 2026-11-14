import ContractForge
open ContractForge

-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.

-- L0 spec

structure Category where
  id     : Nat
  name   : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Input where
  categories : List Category
  deriving DecidableEq, Repr

structure Output where
  categories : List Category
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categories.Nodup
  post := fun i o => o.categories = i.categories ∧
                     o.categories.Nodup

example : Spec.pre { categories := [{ id := 1, name := "Electronics", parent := none },
                                     { id := 2, name := "Computers", parent := some 1 },
                                     { id := 3, name := "Laptops", parent := some 2 }] } ∧
          Spec.post { categories := [{ id := 1, name := "Electronics", parent := none },
                                      { id := 2, name := "Computers", parent := some 1 },
                                      { id := 3, name := "Laptops", parent := some 2 }] }
                    { categories := [{ id := 1, name := "Electronics", parent := none },
                                     { id := 2, name := "Computers", parent := some 1 },
                                     { id := 3, name := "Laptops", parent := some 2 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { categories := x.categories }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
