import ContractForge
open ContractForge

-- 3.1.3/S2: Customers will be able to register, log in, and log out of their accounts.

-- L0 spec

structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  action   : String
  accounts : List Account
  deriving DecidableEq, Repr

structure Output where
  username : String
  logged   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.logged = true ↔
    i.action = "login" ∧
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
    (o.logged = false ↔
    (i.action = "logout" ∧ o.username = i.username) ∨
    (i.action = "register" ∧ i.username ∉ i.accounts.map (·.username)))

example : Spec.pre { username := "john", password := "pass123", action := "login", accounts := [{ username := "john", password := "pass123" }] } ∧ Spec.post { username := "john", password := "pass123", action := "login", accounts := [{ username := "john", password := "pass123" }] } { username := "john", logged := true } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  username : String
  password : String
  logged   : Bool
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i m => m.username = i.username ∧ m.password = i.password ∧ m.logged = false

def ProcessContract : Contract Mid Output where
  pre  := fun m => m.logged = false
  post := fun m o => (o.logged = true ↔
    m.action = "login" ∧
    ∃ a ∈ m.accounts, a.username = m.username ∧ a.password = m.password) ∧
    (o.logged = false ↔
    (m.action = "logout" ∧ o.username = m.username) ∨
    (m.action = "register" ∧ m.username ∉ m.accounts.map (·.username)))

theorem po1 : Contract.Compatible ValidateContract ProcessContract := by
  unfold Contract.Compatible ValidateContract ProcessContract
  intro i m _ h
  cases h with h1 h2
  simp only at h1 h2
  rw [h1, h2]

theorem po2 : Contract.Refines (ValidateContract.seq ProcessContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ProcessContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]