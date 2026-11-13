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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  signedIn : Bool
  items    : List String
  cookie   : String
  ok       : Bool
  deriving DecidableEq, Repr

def SignInContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.signedIn = i.signedIn ∧
                     m.items = i.items ∧
                     m.cookie = i.cookie ∧
                     m.ok = true

def CookieUpdateContract : Contract Mid Output where
  pre  := fun m => m.signedIn = true ∧ m.ok = true
  post := fun m o => o.signedIn = m.signedIn ∧
                     o.items = m.items ∧
                     o.cookie ≠ ""

theorem po1 : Contract.Compatible SignInContract CookieUpdateContract := by
  discharge_po1 [SignInContract, CookieUpdateContract, Spec]

theorem po2 : Contract.Refines (SignInContract.seq CookieUpdateContract) Spec := by
  discharge_po2 [SignInContract, CookieUpdateContract, Spec]

-- L2 SignInContract (success=True)

def SignInContractImpl (x : Input) : Mid :=
  { signedIn := x.signedIn, items := x.items, cookie := x.cookie, ok := true }

theorem SignInContractImpl_ok : SignInContract.Satisfies SignInContractImpl := by
  discharge_po3 [SignInContract, SignInContractImpl]

-- L2 CookieUpdateContract (success=False)

def CookieUpdateContractImpl (x : Mid) : Output :=
  { signedIn := x.signedIn, items := x.items, cookie := x.cookie ++ "updated", ok := true }
