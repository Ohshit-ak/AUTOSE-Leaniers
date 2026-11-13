import ContractForge
open ContractForge

-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.

-- L0 spec

structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  cookie : String
  logged_in : Bool
  deriving DecidableEq, Repr

structure Output where
  cookie : String
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged_in = true
  post := fun i o => o.logged_in = false ∧ o.cookie = i.cookie

example : Spec.pre { cookie := "abc123", logged_in := true } ∧
          Spec.post { cookie := "abc123", logged_in := true }
                    { cookie := "abc123", logged_in := false } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  cookie : String
  logged_in : Bool
  deriving DecidableEq, Repr

def LogoutContract : Contract Input Mid where
  pre  := fun i => i.logged_in = true
  post := fun i m => m.cookie = i.cookie ∧ m.logged_in = false

def SetCookieContract : Contract Mid Output where
  pre  := fun m => m.logged_in = false
  post := fun m o => o.cookie = m.cookie ∧ o.logged_in = false

theorem po1 : Contract.Compatible LogoutContract SetCookieContract := by
  discharge_po1 [LogoutContract, SetCookieContract, Spec]

theorem po2 : Contract.Refines (LogoutContract.seq SetCookieContract) Spec := by
  discharge_po2 [LogoutContract, SetCookieContract, Spec]

-- L2 LogoutContract (success=True)

def LogoutContractImpl (x : Input) : Mid :=
  { cookie := x.cookie, logged_in := false }

theorem LogoutContractImpl_ok : LogoutContract.Satisfies LogoutContractImpl := by
  discharge_po3 [LogoutContract, LogoutContractImpl]

-- L2 SetCookieContract (success=True)

def SetCookieContractImpl (x : Mid) : Output :=
  { cookie := x.cookie, logged_in := false }

theorem SetCookieContractImpl_ok : SetCookieContract.Satisfies SetCookieContractImpl := by
  discharge_po3 [SetCookieContract, SetCookieContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (SetCookieContractImpl ∘ LogoutContractImpl) :=
  Contract.system_sound po1 po2 LogoutContractImpl_ok SetCookieContractImpl_ok
