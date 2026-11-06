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

-- Component 1: Check if the action is 'login'
def LoginCheckContract : Contract Input Output where
  pre  := fun i => i.action = "login"
  post := fun i o => o.logged = true ∧
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password

-- Component 2: Check if the action is 'logout'
def LogoutCheckContract : Contract Input Output where
  pre  := fun i => i.action = "logout" ∧ i.username = o.username
  post := fun i o => o.logged = false

-- Component 3: Check if the action is 'register'
def RegisterCheckContract : Contract Input Output where
  pre  := fun i => i.action = "register" ∧ i.username ∉ i.accounts.map (·.username)
  post := fun i o => o.logged = false

-- Prove PO1: Each component's assumption follows from its predecessor's guarantee
theorem PO1_LoginCheck : Contract.Compatible (LoginCheckContract.post) Spec.pre := by
  intro i o h
  cases h with h1 h2
  simp [h1] at h2
  exact h2

theorem PO1_LogoutCheck : Contract.Compatible (LogoutCheckContract.post) Spec.pre := by
  intro i o h
  cases h with h1 h2
  simp [h1] at h2
  exact h2

theorem PO1_RegisterCheck : Contract.Compatible (RegisterCheckContract.post) Spec.pre := by
  intro i o h
  cases h with h1 h2
  simp [h1] at h2
  exact h2

-- Prove PO2: The composition refines the spec
theorem PO2 : Contract.Refines (LoginCheckContract.seq LogoutCheckContract.seq RegisterCheckContract) Spec := by
  intro i o h
  cases h with h1 h2
  simp [h1] at h2
  exact h2

-- Example to check the correctness
example : Spec.pre { username := "john", password := "pass123", action := "login", accounts := [{ username := "john", password := "pass123" }] } ∧ Spec.post { username := "john", password := "pass123", action := "login", accounts := [{ username := "john", password := "pass123" }] } { username := "john", logged := true } := by
  unfold Spec; decide

example : Spec.pre { username := "john", password := "pass123", action := "logout", accounts := [{ username := "john", password := "pass123" }] } ∧ Spec.post { username := "john", password := "pass123", action := "logout", accounts := [{ username := "john", password := "pass123" }] } { username := "john", logged := false } := by
  unfold Spec; decide

example : Spec.pre { username := "john", password := "pass123", action := "register", accounts := [{ username := "john", password := "pass123" }] } ∧ Spec.post { username := "john", password := "pass123", action := "register", accounts := [{ username := "john", password := "pass123" }] } { username := "john", logged := false } := by
  unfold Spec; decide