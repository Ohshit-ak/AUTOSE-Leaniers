import ContractForge
open ContractForge

-- UC-sales-person-logout-sales-person: Logout Sales Person: Logout the Sales Person account on the system.

-- L0 spec

structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  cookie : String
  signedIn : Bool
  deriving DecidableEq, Repr

structure Output where
  cookie : String
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = false ∧ o.cookie = i.cookie

example : Spec.pre { cookie := "abc123", signedIn := true } ∧
          Spec.post { cookie := "abc123", signedIn := true }
                    { signedIn := false, cookie := "abc123" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  cookie : String
  signedIn : Bool
  deriving DecidableEq, Repr

def UnsignContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.cookie = i.cookie ∧ m.signedIn = false

def ReturnCookieContract : Contract Mid Output where
  pre  := fun m => m.signedIn = false
  post := fun m o => o.cookie = m.cookie ∧ o.signedIn = false

theorem po1 : Contract.Compatible UnsignContract ReturnCookieContract := by
  discharge_po1 [UnsignContract, ReturnCookieContract, Spec]

theorem po2 : Contract.Refines (UnsignContract.seq ReturnCookieContract) Spec := by
  discharge_po2 [UnsignContract, ReturnCookieContract, Spec]

-- L2 UnsignContract (success=True)

def UnsignContractImpl (x : Input) : Mid :=
  { cookie := x.cookie, signedIn := false }

theorem UnsignContractImpl_ok : UnsignContract.Satisfies UnsignContractImpl := by
  discharge_po3 [UnsignContract, UnsignContractImpl]

-- L2 ReturnCookieContract (success=True)

def ReturnCookieContractImpl (x : Mid) : Output :=
  { cookie := x.cookie, signedIn := false }

theorem ReturnCookieContractImpl_ok : ReturnCookieContract.Satisfies ReturnCookieContractImpl := by
  discharge_po3 [ReturnCookieContract, ReturnCookieContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ReturnCookieContractImpl ∘ UnsignContractImpl) :=
  Contract.system_sound po1 po2 UnsignContractImpl_ok ReturnCookieContractImpl_ok
