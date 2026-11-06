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

-- L1 architect (success=False)

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

-- Decompose the spec into two components

def LoginCheckContract : Contract Input Session where
  pre  := fun i => i.logged_in = true
  post := fun i s => s.cookie = i.cookie

def LogoutContract : Contract Session Output where
  pre  := fun s => true
  post := fun s o => o.logged_in = false ∧ o.cookie = s.cookie

-- Prove PO1: each component's assumption follows from its predecessor's guarantee
theorem PO1_LoginCheck : Contract.Compatible LoginCheckContract.Spec LogoutContract.pre := by
  intros s
  simp [LoginCheckContract.post, LogoutContract.pre]
  exact dec_trivial

theorem PO1_Logout : Contract.Compatible LogoutContract.Spec LoginCheckContract.post := by
  intros s
  simp [LogoutContract.post, LoginCheckContract.post]
  exact dec_trivial

-- Prove PO2: the composition refines the spec
theorem PO2 : Contract.Refines (LoginCheckContract.seq LogoutContract) Spec := by
  unfold LoginCheckContract LogoutContract Spec
  simp [Contract.seq]
  apply Contract.system_sound
  discharge_po

-- Example to verify the contracts
example : Spec.pre { cookie := "abc123", logged_in := true } ∧
          Spec.post { cookie := "abc123", logged_in := true }
                    { cookie := "abc123", logged_in := false } := by
  unfold Spec; decide