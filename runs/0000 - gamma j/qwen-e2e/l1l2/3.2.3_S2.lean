import ContractForge
open ContractForge

-- 3.2.3/S2: The inventory management will allow for administrators to update the categories, the products placed in categories, and the specific product details.

-- L0 spec

structure Category where
  id : Nat
  name : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Product where
  id : Nat
  name : String
  category : Nat
  details : String
  deriving DecidableEq, Repr

structure Input where
  categories : List Category
  products : List Product
  deriving DecidableEq, Repr

structure Output where
  categories : List Category
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categories.Nodup ∧ i.products.Nodup
  post := fun i o => o.categories = i.categories ∧
                     o.products = i.products

example : Spec.pre { categories := [{ id := 1, name := "Electronics", parent := none },
                                      { id := 2, name := "Books", parent := none }],
                     products := [{ id := 1, name := "iPhone", category := 1, details := "Smartphone" },
                                  { id := 2, name := "Harry Potter", category := 2, details := "Fantasy novel" }] } ∧
          Spec.post { categories := [{ id := 1, name := "Electronics", parent := none },
                                      { id := 2, name := "Books", parent := none }],
                      products := [{ id := 1, name := "iPhone", category := 1, details := "Smartphone" },
                                   { id := 2, name := "Harry Potter", category := 2, details := "Fantasy novel" }] }
                    { categories := [{ id := 1, name := "Electronics", parent := none },
                                     { id := 2, name := "Books", parent := none }],
                      products := [{ id := 1, name := "iPhone", category := 1, details := "Smartphone" },
                                   { id := 2, name := "Harry Potter", category := 2, details := "Fantasy novel" }] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Category where
  id : Nat
  name : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Product where
  id : Nat
  name : String
  category : Nat
  details : String
  deriving DecidableEq, Repr

structure Input where
  categories : List Category
  products : List Product
  deriving DecidableEq, Repr

structure Output where
  categories : List Category
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categories.Nodup ∧ i.products.Nodup
  post := fun i o => o.categories = i.categories ∧
                     o.products = i.products

-- Component 1: Ensure categories are not modified
def CategoryContract : Contract (Input × List Category) (Output × List Category) where
  pre  := fun (i, cats) => i.categories.Nodup ∧ cats = i.categories
  post := fun (i, cats) (o, cats') => cats' = cats ∧ o.categories = i.categories

-- Component 2: Ensure products are not modified
def ProductContract : Contract (Input × List Product) (Output × List Product) where
  pre  := fun (i, prods) => i.products.Nodup ∧ prods = i.products
  post := fun (i, prods) (o, prods') => prods' = prods ∧ o.products = i.products

-- Prove PO1: CategoryContract and ProductContract are compatible with Spec
theorem PO1_Category : Contract.Compatible CategoryContract Spec := by
  intros i o
  unfold CategoryContract Spec
  simp [i, o]
  constructor
  -- First part
  simp [i, o]
  -- Second part
  simp [i, o]

theorem PO1_Product : Contract.Compatible ProductContract Spec := by
  intros i o
  unfold ProductContract Spec
  simp [i, o]
  constructor
  -- First part
  simp [i, o]
  -- Second part
  simp [i, o]

-- Prove PO2: Composition of CategoryContract and ProductContract refines Spec
theorem PO2 : Contract.Refines (CategoryContract.seq ProductContract) Spec := by
  intros i o
  unfold CategoryContract ProductContract Spec
  simp [i, o]
  constructor
  -- First part
  simp [i, o]
  -- Second part
  simp [i, o]

-- Discharge PO1 and PO2
discharge_po