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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  productToAdd : Product
  inCart : Bool
  deriving DecidableEq, Repr

def AddProductContract : Contract Input Mid where
  pre  := fun i => true
  post := fun i m => m.productToAdd = i.productToAdd ∧ m.inCart = (i.cart.contains i.productToAdd)

def UpdateCartContract : Contract Mid Output where
  pre  := fun m => m.inCart
  post := fun m o => o.cart.length = m.inCart + 1 ∧ o.cart.contains m.productToAdd
