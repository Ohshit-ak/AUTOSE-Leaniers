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

structure Mid where
  signedIn : Bool
  items    : List String
  cookie   : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.signedIn = i.signedIn ∧
                     m.items = i.items ∧
                     m.cookie = i.cookie

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.signedIn = true
  post := fun m o => o.signedIn = m.signedIn ∧
                     o.items = m.items ∧
                     o.cookie = m.cookie

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  split
  · exact h.2.1
  · exact h.2.2
  · exact h.2.3

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, fun i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩ => by
    simp only at *
    rw [ho, hp, hq]⟩