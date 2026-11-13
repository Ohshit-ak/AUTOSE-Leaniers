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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  matchedAccount : Option Account
  action         : String
  username       : String
  accounts       : List Account
  deriving DecidableEq, Repr

def AuthenticateContract : Contract Input Mid where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i m => m.matchedAccount ≠ none ∧
    (m.matchedAccount.get! = { username := i.username, password := i.password } ∧
    (i.action = "login" ∨ i.action = "logout" ∨ i.action = "register")) ∧
    (m.matchedAccount = none ↔ i.action = "register" ∧ i.username ∉ i.accounts.map (·.username))

def UpdateLoggedContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.logged = true ↔ m.matchedAccount ≠ none ∧ m.action = "login") ∧
    (o.logged = false ↔ (m.matchedAccount = none ∧ m.action = "logout") ∨
    (m.matchedAccount = none ∧ m.action = "register" ∧ m.username ∉ m.accounts.map (·.username)))
