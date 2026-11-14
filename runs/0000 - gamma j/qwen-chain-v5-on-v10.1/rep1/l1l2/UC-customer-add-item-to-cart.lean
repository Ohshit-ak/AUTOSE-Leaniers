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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { signedIn := x.signedIn,
    items := x.items,
    cookie := "cartDetails" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
