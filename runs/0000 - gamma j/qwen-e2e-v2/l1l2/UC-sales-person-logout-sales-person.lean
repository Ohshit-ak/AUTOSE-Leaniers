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

-- L1 architect (success=True)

structure Mid where
  cookie : String
  signedIn : Bool := false
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.signedIn = false ∧ m.cookie = i.cookie

def UpdateContract : Contract Mid Output where
  pre  := fun m => m.signedIn = false
  post := fun m o => o.signedIn = false ∧ o.cookie = m.cookie

theorem po1 : Contract.Compatible ValidateContract UpdateContract := by
  discharge_po [Spec, UpdateContract, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq UpdateContract) Spec := by
  discharge_po [Spec, UpdateContract, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { cookie := i.cookie, signedIn := false }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [Spec, UpdateContract, ValidateContract, ValidateContractImpl]

-- L2 UpdateContract (success=True)

def UpdateContractImpl (m : Mid) : Output := { signedIn := false, cookie := m.cookie }

theorem UpdateContractImpl_ok : UpdateContract.Satisfies UpdateContractImpl := by
  discharge_po [UpdateContract, UpdateContractImpl]