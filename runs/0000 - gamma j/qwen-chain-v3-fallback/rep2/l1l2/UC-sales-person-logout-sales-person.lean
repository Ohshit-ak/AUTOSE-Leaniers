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

def LogOutContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.cookie = i.cookie ∧ m.signedIn = false

def UpdateCookieContract : Contract Mid Output where
  pre  := fun m => m.signedIn = false
  post := fun m o => o.cookie = m.cookie ∧ o.signedIn = false

theorem po1 : Contract.Compatible LogOutContract UpdateCookieContract := by
  discharge_po1 [LogOutContract, UpdateCookieContract, Spec]

theorem po2 : Contract.Refines (LogOutContract.seq UpdateCookieContract) Spec := by
  discharge_po2 [LogOutContract, UpdateCookieContract, Spec]

-- L2 LogOutContract (success=True)

def LogOutContractImpl (x : Input) : Mid :=
  { cookie := x.cookie, signedIn := false }

theorem LogOutContractImpl_ok : LogOutContract.Satisfies LogOutContractImpl := by
  discharge_po3 [LogOutContract, LogOutContractImpl]

-- L2 UpdateCookieContract (success=True)

def UpdateCookieContractImpl (x : Mid) : Output :=
  { cookie := x.cookie, signedIn := false }

theorem UpdateCookieContractImpl_ok : UpdateCookieContract.Satisfies UpdateCookieContractImpl := by
  discharge_po3 [UpdateCookieContract, UpdateCookieContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (UpdateCookieContractImpl ∘ LogOutContractImpl) :=
  Contract.system_sound po1 po2 LogOutContractImpl_ok UpdateCookieContractImpl_ok
