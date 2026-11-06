import ContractForge
open ContractForge

-- 3.3.3/S3: The customer will also be able to add to or remove products from the shopping cart prior to checkout and order confirmation.

-- L0 spec

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  cart : List Product
  deriving DecidableEq, Repr

structure Output where
  cart : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.Nodup
  post := fun i o => o.cart = i.cart

example : Spec.pre { cart := [{ name := "Product A", price := 100 }] } ∧
          Spec.post { cart := [{ name := "Product A", price := 100 }] }
                    { cart := [{ name := "Product A", price := 100 }] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  cart : List Product
  deriving DecidableEq, Repr

structure Output where
  cart : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.Nodup
  post := fun i o => o.cart = i.cart

-- Component 1: Ensure the input cart is not modified
def Component1Contract : Contract Input Input where
  pre  := fun i => i.cart.Nodup
  post := fun i i' => i' = i

-- Component 2: Ensure the output cart is the same as the input cart
def Component2Contract : Contract Input Output where
  pre  := fun i => i.cart.Nodup
  post := fun i o => o.cart = i.cart

-- Prove PO1: Component1Contract is compatible with the empty contract
theorem PO1 : Contract.Compatible (Contract.Empty : Contract Input Input) Component1Contract := by
  discharge_po

-- Prove PO1: Component2Contract is compatible with Component1Contract
theorem PO1' : Contract.Compatible Component1Contract Component2Contract := by
  discharge_po

-- Prove PO2: The composition of Component1Contract and Component2Contract refines Spec
theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  unfold Component1Contract Component2Contract Spec; discharge_po