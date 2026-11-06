import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.

-- L0 spec

structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  account  : Account
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" -- Customer account must be registered
  post := fun i o => (o.logged = true ↔ i.password = i.account.password) ∧
                     (o.logged = false ↔ i.password ≠ i.account.password) ∧
                     (o.cookie ≠ "" ↔ o.logged = true)

example : Spec.pre { username := "john", password := "pass123", email := "john@example.com", account := { username := "john", password := "pass123", email := "john@example.com" } } ∧ Spec.post { username := "john", password := "pass123", email := "john@example.com", account := { username := "john", password := "pass123", email := "john@example.com" } } { logged := true, cookie := "abc123" } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.email ≠ ""
  post := fun i m => (m.logged = true ↔ i.password = i.account.password) ∧
                     (m.logged = false ↔ i.password ≠ i.account.password) ∧
                     (m.cookie ≠ "" ↔ m.logged = true)

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.logged = true
  post := fun m o => o.logged = m.logged ∧ o.cookie = m.cookie

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  simp only at h
  rw [h.2.1, h.2.2]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]