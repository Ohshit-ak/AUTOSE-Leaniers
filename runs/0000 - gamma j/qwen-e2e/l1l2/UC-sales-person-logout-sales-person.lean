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

-- L1 architect (success=False)

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

-- Decompose the spec into two components
def CookieContract : Contract Input Input where
  pre  := fun i => i.signedIn = true
  post := fun i i' => i'.cookie = i.cookie

def SignedInContract : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = false ∧ o.cookie = i.cookie

-- Prove PO1: CookieContract's assumption follows from Spec's guarantee
theorem PO1_CookieContract : Contract.Compatible CookieContract Spec :=
  by
    intro i o hpre hpost
    unfold CookieContract Spec
    simp [hpost]
    exact hpre

-- Prove PO2: CookieContract refines the spec
theorem PO2_CookieContract : Contract.Refines (CookieContract.seq Spec) Spec :=
  by
    intro i o hpre hpost
    unfold CookieContract Spec
    simp [hpost]
    exact hpre

-- Prove PO1: SignedInContract's assumption follows from CookieContract's guarantee
theorem PO1_SignedInContract : Contract.Compatible SignedInContract CookieContract :=
  by
    intro i i' hpre hpost
    unfold CookieContract SignedInContract
    simp [hpost]
    exact hpre

-- Prove PO2: SignedInContract refines the spec
theorem PO2_SignedInContract : Contract.Refines (SignedInContract.seq CookieContract) Spec :=
  by
    intro i o hpre hpost
    unfold CookieContract SignedInContract Spec
    simp [hpost]
    exact hpre

-- Prove PO1: the composition of the two contracts refines the spec
theorem PO1_Composition : Contract.Compatible (SignedInContract.seq CookieContract) Spec :=
  by
    intro i o hpre hpost
    unfold CookieContract SignedInContract Spec
    simp [hpost]
    exact hpre

-- Prove PO2: the composition of the two contracts refines the spec
theorem PO2_Composition : Contract.Refines (SignedInContract.seq CookieContract) Spec :=
  by
    intro i o hpre hpost
    unfold CookieContract SignedInContract Spec
    simp [hpost]
    exact hpre

-- System soundness
theorem PO1_SystemSound : Contract.Compatible (SignedInContract.seq CookieContract) Spec :=
  by
    discharge_po

-- System soundness
theorem PO2_SystemSound : Contract.Refines (SignedInContract.seq CookieContract) Spec :=
  by
    discharge_po