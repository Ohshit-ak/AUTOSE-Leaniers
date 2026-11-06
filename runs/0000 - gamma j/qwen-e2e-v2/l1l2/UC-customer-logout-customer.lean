import ContractForge
open ContractForge

-- UC-customer-logout-customer: Logout Customer: Logout the customer account on the system.

-- L0 spec

structure Input where
  signedIn : Bool
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = false

example : Spec.pre { signedIn := true } ∧
          Spec.post { signedIn := true } { signedIn := false } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  signedIn : Bool
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.signedIn = true
  post := fun i m => m.signedIn = i.signedIn

def SignOutContract : Contract Mid Output where
  pre  := fun m => m.signedIn = true
  post := fun m o => o.signedIn = false

theorem po1 : Contract.Compatible ValidateContract SignOutContract := by
  discharge_po [SignOutContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq SignOutContract) Spec := by
  discharge_po [SignOutContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := { signedIn := i.signedIn }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [SignOutContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 SignOutContract (success=True)

def SignOutContractImpl (m : Mid) : Output := { signedIn := false }

theorem SignOutContractImpl_ok : SignOutContract.Satisfies SignOutContractImpl := by
  discharge_po [SignOutContract, SignOutContractImpl]