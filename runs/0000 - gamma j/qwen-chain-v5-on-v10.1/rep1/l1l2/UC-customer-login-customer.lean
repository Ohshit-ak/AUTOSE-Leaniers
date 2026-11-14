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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def AuthenticateContract : Contract Input Mid where
  pre  := fun i => i.email ≠ ""
  post := fun i m => m.logged = (i.password = i.account.password) ∧ m.cookie = "abc123" -- Assume a fixed cookie value for simplicity

def GenerateOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.logged = m.logged) ∧ (o.cookie = m.cookie) ∧ (o.logged = true ↔ o.cookie ≠ "")

theorem po1 : Contract.Compatible AuthenticateContract GenerateOutputContract := by
  discharge_po1 [AuthenticateContract, GenerateOutputContract, Spec]

theorem po2 : Contract.Refines (AuthenticateContract.seq GenerateOutputContract) Spec := by
  discharge_po2 [AuthenticateContract, GenerateOutputContract, Spec]

-- L2 AuthenticateContract (success=True)

def AuthenticateContractImpl (x : Input) : Mid :=
  { logged := x.password = x.account.password,
    cookie := "abc123" }

theorem AuthenticateContractImpl_ok : AuthenticateContract.Satisfies AuthenticateContractImpl := by
  discharge_po3 [AuthenticateContract, AuthenticateContractImpl]

-- L2 GenerateOutputContract (success=False)

def GenerateOutputContractImpl (x : Mid) : Output :=
  { logged := x.logged,
    cookie := if x.cookie ≠ "" then "abc123" else "" }
