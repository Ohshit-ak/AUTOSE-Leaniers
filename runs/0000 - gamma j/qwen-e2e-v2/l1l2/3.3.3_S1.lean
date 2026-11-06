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

-- L1 architect (success=True)

structure Mid where
  cart : List Product
  productToAdd : Product
  deriving DecidableEq, Repr

def AddProductContract : Contract Input Mid where
  pre  := fun i => true
  post := fun i m => m.cart.length = i.cart.length + 1 ∧
                     m.cart.contains i.productToAdd

def UpdateCartContract : Contract Mid Output where
  pre  := fun m => m.cart.length > 0
  post := fun m o => o.cart = m.cart

theorem po1 : Contract.Compatible AddProductContract UpdateCartContract := by
  discharge_po [AddProductContract, Spec, UpdateCartContract]

theorem po2 : Contract.Refines (AddProductContract.seq UpdateCartContract) Spec := by
  discharge_po [AddProductContract, Spec, UpdateCartContract]

-- L2 AddProductContract (success=True)

def AddProductContractImpl (i : Input) : Mid := 
  { cart := i.cart ++ [i.productToAdd], 
    productToAdd := i.productToAdd }

theorem AddProductContractImpl_ok : AddProductContract.Satisfies AddProductContractImpl := by
  discharge_po [AddProductContract, AddProductContractImpl, Spec, UpdateCartContract]

-- L2 UpdateCartContract (success=True)

def UpdateCartContractImpl (m : Mid) : Output := { cart := m.cart }

theorem UpdateCartContractImpl_ok : UpdateCartContract.Satisfies UpdateCartContractImpl := by
  discharge_po [UpdateCartContract, UpdateCartContractImpl]