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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  categories : List Category
  ok         : Bool
  deriving DecidableEq, Repr

def CheckNodupContract : Contract Input Mid where
  pre  := fun i => i.categories.Nodup
  post := fun i m => m.categories = i.categories ∧ m.ok = true ↔ i.categories.Nodup

def CopyCategoriesContract : Contract Mid Output where
  pre  := fun m => m.ok
  post := fun m o => o.categories = m.categories ∧ o.categories.Nodup

theorem po1 : Contract.Compatible CheckNodupContract CopyCategoriesContract := by
  discharge_po1 [CheckNodupContract, CopyCategoriesContract, Spec]

theorem po2 : Contract.Refines (CheckNodupContract.seq CopyCategoriesContract) Spec := by
  discharge_po2 [CheckNodupContract, CopyCategoriesContract, Spec]

-- L2 CheckNodupContract (success=True)

def CheckNodupContractImpl (x : Input) : Mid :=
  { categories := x.categories, ok := true }

theorem CheckNodupContractImpl_ok : CheckNodupContract.Satisfies CheckNodupContractImpl := by
  discharge_po3 [CheckNodupContract, CheckNodupContractImpl]

-- L2 CopyCategoriesContract (success=False)

def CopyCategoriesContractImpl (x : Mid) : Output :=
  { categories := x.categories, ok := x.ok }
