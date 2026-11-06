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

-- L1 architect (success=False)

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

-- Decompose the spec into two components
def C1Contract : Contract Input Output := 
  { pre  := fun i => i.categories.Nodup,
    post := fun i o => o.categories = i.categories }

def C2Contract : Contract Output Output := 
  { pre  := fun o => o.categories.Nodup,
    post := fun o o' => o' = o }

-- Prove PO1: each component's assumption follows from its predecessor's guarantee
theorem PO1 : Contract.Compatible C1Contract Spec := 
  by
    intro i o
    simp [C1Contract.post, Spec.post]
    exact Eq.refl (o.categories = i.categories)

theorem PO1' : Contract.Compatible C2Contract C1Contract := 
  by
    intro o o'
    simp [C2Contract.post, C1Contract.post]
    exact Eq.refl (o' = o)

-- Prove PO2: the composition refines the spec
theorem PO2 : Contract.Refines (C1Contract.seq C2Contract) Spec := 
  by
    intro i o
    simp [C1Contract.post, C2Contract.post, Spec.post]
    exact Eq.refl (o.categories = i.categories ∧ o.categories.Nodup)

-- Example check
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