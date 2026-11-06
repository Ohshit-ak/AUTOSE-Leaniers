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

-- L1 architect (success=False)

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

-- Decompose the spec into two components

def AddProductContract : Contract Input Output := 
  { pre  := fun i => true
    post := fun i o => o.cart.length = i.cart.length + 1 }

def ContainsProductContract : Contract Output Output := 
  { pre  := fun o => o.cart.contains i.productToAdd
    post := fun o o' => o' = o }

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1_AddProduct : Contract.Compatible (AddProductContract) Spec := 
  by
    intro i o
    simp [AddProductContract.post, Spec.post]
    split
    { exact add_length }
    { exact contains_add }

theorem PO1_ContainsProduct : Contract.Compatible (ContainsProductContract) AddProductContract := 
  by
    intro o o'
    simp [ContainsProductContract.pre, AddProductContract.post, ContainsProductContract.post]
    split
    { exact contains_same }
    { exact id }

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (AddProductContract.seq ContainsProductContract) Spec := 
  by
    intro i o
    simp [AddProductContract.post, ContainsProductContract.post, Spec.post]
    split
    { exact add_length }
    { exact contains_add }

-- The complete corrected file

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

def AddProductContract : Contract Input Output := 
  { pre  := fun i => true
    post := fun i o => o.cart.length = i.cart.length + 1 }

def ContainsProductContract : Contract Output Output := 
  { pre  := fun o => o.cart.contains i.productToAdd
    post := fun o o' => o' = o }

theorem PO1_AddProduct : Contract.Compatible (AddProductContract) Spec := 
  by
    intro i o
    simp [AddProductContract.post, Spec.post]
    split
    { exact add_length }
    { exact contains_add }

theorem PO1_ContainsProduct : Contract.Compatible (ContainsProductContract) AddProductContract := 
  by
    intro o o'
    simp [ContainsProductContract.pre, AddProductContract.post, ContainsProductContract.post]
    split
    { exact contains_same }
    { exact id }

theorem PO2 : Contract.Refines (AddProductContract.seq ContainsProductContract) Spec := 
  by
    intro i o
    simp [AddProductContract.post, ContainsProductContract.post, Spec.post]
    split
    { exact add_length }
    { exact contains_add }

-- Theorems for the proofs
theorem add_length : o.cart.length = i.cart.length + 1 → o.cart.length = i.cart.length + 1 := 
  by
    intro h
    exact h

theorem contains_add : o.cart.contains i.productToAdd → o.cart.contains i.productToAdd := 
  by
    intro h
    exact h

theorem contains_same : o = o' → o.cart.contains i.productToAdd → o'.cart.contains i.productToAdd := 
  by
    intro h1 h2
    exact h2