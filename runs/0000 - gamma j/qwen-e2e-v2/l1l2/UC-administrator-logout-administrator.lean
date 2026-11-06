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

-- L1 architect (success=True)

structure Mid where
  cookie : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.logged_in = true
  post := fun i m => m.cookie = i.cookie

def LogoutContract : Contract Mid Output where
  pre  := fun m => m.cookie = m.cookie
  post := fun m o => o.logged_in = false ∧ o.cookie = m.cookie

theorem po1 : Contract.Compatible ValidateContract LogoutContract := by
  discharge_po [LogoutContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq LogoutContract) Spec := by
  discharge_po [LogoutContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { cookie := i.cookie }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [LogoutContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 LogoutContract (success=True)

def LogoutContractImpl (m : Mid) : Output := { cookie := m.cookie, logged_in := false }

theorem LogoutContractImpl_ok : LogoutContract.Satisfies LogoutContractImpl := by
  discharge_po [LogoutContract, LogoutContractImpl, Spec, ValidateContract]