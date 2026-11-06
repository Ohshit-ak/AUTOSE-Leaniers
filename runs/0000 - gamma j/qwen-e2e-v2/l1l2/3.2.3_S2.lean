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

-- L1 architect (success=True)

structure Mid where
  categories : List Category
  products : List Product
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.categories.Nodup ∧ i.products.Nodup
  post := fun i m => m.categories = i.categories ∧ m.products = i.products

def CopyContract : Contract Mid Output where
  pre  := fun m => m.categories.Nodup ∧ m.products.Nodup
  post := fun m o => o.categories = m.categories ∧ o.products = m.products

theorem po1 : Contract.Compatible ValidateContract CopyContract := by
  discharge_po [CopyContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq CopyContract) Spec := by
  discharge_po [CopyContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { categories := i.categories, products := i.products }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [CopyContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 CopyContract (success=True)

def CopyContractImpl (m : Mid) : Output := { categories := m.categories, products := m.products }

theorem CopyContractImpl_ok : CopyContract.Satisfies CopyContractImpl := by
  discharge_po [CopyContract, CopyContractImpl, Spec, ValidateContract]