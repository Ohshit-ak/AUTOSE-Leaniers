import ContractForge
open ContractForge

-- UC-customer-add-item-to-cart: Add Item To Cart: Customer adds item(s) in the cart

-- L0 spec

structure Input where
  signedIn : Bool
  items    : List String
  cookie   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  items    : List String
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.items = i.items ∧
                     o.cookie ≠ ""

example : Spec.pre { signedIn := true, items := ["item1", "item2"], cookie := "cartDetails" } ∧
          Spec.post { signedIn := true, items := ["item1", "item2"], cookie := "cartDetails" }
                    { signedIn := true, items := ["item1", "item2"], cookie := "cartDetails" } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  signedIn : Bool
  items    : List String
  cookie   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  items    : List String
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.items = i.items ∧
                     o.cookie ≠ ""

-- Component 1: Ensure signedIn remains unchanged
def Component1Contract : Contract Input Input := 
  { pre  := fun i => i.signedIn = true,
    post := fun i i' => i' = i }

-- Component 2: Ensure items remain unchanged
def Component2Contract : Contract Input Input := 
  { pre  := fun i => i.signedIn = true,
    post := fun i i' => i'.items = i.items }

-- Component 3: Ensure cookie is updated
def Component3Contract : Contract Input Output := 
  { pre  := fun i => i.signedIn = true,
    post := fun i o => o.cookie ≠ "" }

-- Prove PO1: Each component's assumption follows from its predecessor's guarantee
example : Contract.Compatible Component1Contract Spec := by
  unfold Component1Contract Spec; discharge_po

example : Contract.Compatible Component2Contract Component1Contract := by
  unfold Component2Contract Component1Contract; discharge_po

example : Contract.Compatible Component3Contract Component2Contract := by
  unfold Component3Contract Component2Contract; discharge_po

-- Prove PO2: The composition refines the spec
example : Contract.Refines (Component1Contract.seq Component2Contract).seq Component3Contract Spec := by
  unfold Component1Contract Component2Contract Component3Contract Spec; discharge_po