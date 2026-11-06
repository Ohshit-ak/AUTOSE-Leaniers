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

-- L1 architect (success=False)

structure Input where
  signedIn : Bool
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = false

-- Decompose the spec into two components

def SignOutContract : Contract Input Output := 
  { pre  := fun i => i.signedIn = true
    post := fun i o => o.signedIn = false }

-- Prove PO1: SignOutContract's assumption follows from Spec's guarantee
theorem PO1_SignOutContract : Contract.Compatible Spec.pre SignOutContract.pre := by
  intro i
  simp [Spec.pre, SignOutContract.pre]
  exact dec_trivial

-- Prove PO2: The composition refines the spec
theorem PO2_SignOutContract : Contract.Refines (Spec.pre.seq SignOutContract.post) Spec.post := by
  intro i o
  simp [Spec.post, SignOutContract.post, Spec.pre, SignOutContract.pre]
  exact dec_trivial

-- Combine the contracts to form the overall system
def System : Contract Input Output := 
  { pre  := Spec.pre
    post := SignOutContract.post }

-- Prove PO1: System's assumption follows from Spec's guarantee
theorem PO1_System : Contract.Compatible Spec.pre System.pre := by
  simp [System.pre, Spec.pre]
  exact dec_trivial

-- Prove PO2: The composition refines the spec
theorem PO2_System : Contract.Refines (Spec.pre.seq System.post) Spec.post := by
  simp [System.post, Spec.post, System.pre, Spec.pre]
  exact dec_trivial