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

-- L1 architect (success=False)

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

-- Decompose the spec into two components

def FilterProductsContract : Contract (Input × String × Nat) (List Product) where
  pre  := fun (i, name, price) => i.products.Nodup
  post := fun (i, name, price) o => o = i.products.filter (fun p => p.name ≠ name ∧ p.price ≠ price)

def FinalOutputContract : Contract (List Product) Output where
  pre  := fun o => True -- No assumptions needed
  post := fun o o' => o' = { products := o }

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem FilterProductsCompatible : Contract.Compatible (FilterProductsContract) (Spec) :=
  by
    intro i
    simp [FilterProductsContract, Spec]
    unfold Contract.pre
    unfold Contract.post
    simp [List.filter, List.Nodup.filter]
    rw [List.filter_eq_filter]
    simp [List.filter, List.Nodup.filter]
    exact List.Nodup.filter

-- Prove PO2: the composition refines the spec

theorem FilterProductsRefines : Contract.Refines (FilterProductsContract.seq FinalOutputContract) Spec :=
  by
    intro i
    simp [FilterProductsContract, FinalOutputContract, Spec]
    unfold Contract.pre
    unfold Contract.post
    simp [List.filter, List.Nodup.filter]
    rw [List.filter_eq_filter]
    simp [List.filter, List.Nodup.filter]
    exact List.Nodup.filter

-- Example to check the contracts
example : Spec.pre { products := [{ name := "apple", price := 100 },
                                   { name := "banana", price := 200 }],
                     name := "apple", price := 100 } ∧
          Spec.post { products := [{ name := "apple", price := 100 },
                                    { name := "banana", price := 200 }],
                      name := "apple", price := 100 }
                    { products := [{ name := "banana", price := 200 }] } := by
  unfold Spec; decide