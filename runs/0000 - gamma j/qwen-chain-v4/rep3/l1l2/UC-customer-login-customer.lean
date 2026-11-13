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
  post := fun i m => (m.logged = true ↔ i.password = i.account.password) ∧
                     (m.logged = false ↔ i.password ≠ i.account.password) ∧
                     (m.cookie = "" ↔ m.logged = false)

def GenerateCookieContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.logged = m.logged) ∧ (o.cookie ≠ "" ↔ m.logged = true)

theorem po1 : Contract.Compatible AuthenticateContract GenerateCookieContract := by
  discharge_po1 [AuthenticateContract, GenerateCookieContract, Spec]

theorem po2 : Contract.Refines (AuthenticateContract.seq GenerateCookieContract) Spec := by
  discharge_po2 [AuthenticateContract, GenerateCookieContract, Spec]

-- L2 AuthenticateContract (success=True)

def AuthenticateContractImpl (x : Input) : Mid :=
  { logged := decide (x.password = x.account.password), cookie := if x.password = x.account.password then "abc123" else "" }

theorem AuthenticateContractImpl_ok : AuthenticateContract.Satisfies AuthenticateContractImpl := by
  discharge_po3 [AuthenticateContract, AuthenticateContractImpl]

-- L2 GenerateCookieContract (success=True)

def GenerateCookieContractImpl (x : Mid) : Output :=
  { logged := x.logged, cookie := if x.logged then "abc123" else "" }

theorem GenerateCookieContractImpl_ok : GenerateCookieContract.Satisfies GenerateCookieContractImpl := by
  discharge_po3 [GenerateCookieContract, GenerateCookieContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (GenerateCookieContractImpl ∘ AuthenticateContractImpl) :=
  Contract.system_sound po1 po2 AuthenticateContractImpl_ok GenerateCookieContractImpl_ok
