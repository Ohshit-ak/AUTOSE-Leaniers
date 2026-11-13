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

def LogoutContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.cookie = i.cookie ∧ m.signedIn = false

def UpdateCookieContract : Contract Mid Output where
  pre  := fun m => m.signedIn = false
  post := fun m o => o.cookie = m.cookie ∧ o.signedIn = false

theorem po1 : Contract.Compatible LogoutContract UpdateCookieContract := by
  discharge_po1 [LogoutContract, UpdateCookieContract, Spec]

theorem po2 : Contract.Refines (LogoutContract.seq UpdateCookieContract) Spec := by
  discharge_po2 [LogoutContract, UpdateCookieContract, Spec]

-- L2 LogoutContract (success=True)

def LogoutContractImpl (x : Input) : Mid :=
  { cookie := x.cookie, signedIn := false }

theorem LogoutContractImpl_ok : LogoutContract.Satisfies LogoutContractImpl := by
  discharge_po3 [LogoutContract, LogoutContractImpl]

-- L2 UpdateCookieContract (success=True)

def UpdateCookieContractImpl (x : Mid) : Output :=
  { cookie := x.cookie, signedIn := false }

theorem UpdateCookieContractImpl_ok : UpdateCookieContract.Satisfies UpdateCookieContractImpl := by
  discharge_po3 [UpdateCookieContract, UpdateCookieContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (UpdateCookieContractImpl ∘ LogoutContractImpl) :=
  Contract.system_sound po1 po2 LogoutContractImpl_ok UpdateCookieContractImpl_ok
