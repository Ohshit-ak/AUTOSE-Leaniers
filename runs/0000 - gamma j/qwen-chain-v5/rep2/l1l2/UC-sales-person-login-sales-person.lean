import ContractForge
open ContractForge

-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.

-- L0 spec

structure Input where
  username : String
  password : String
  email    : String
  cookie   : Option String
  deriving DecidableEq, Repr

structure Output where
  loggedIn : Bool
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => (o.loggedIn = true ↔
    (o.cookie.isSome → o.cookie.getD "" ≠ "") ∧
    (o.cookie.isNone → i.email.toList.any (· = ' '))) ∧
    (o.loggedIn = false → o.cookie = i.cookie ∧
    (i.cookie.isNone → o.loggedIn = false ∧
    o.cookie = i.cookie ∧
    i.email.toList.any (· = ' ') = true ∧
    i.password.toList.all Char.isAlphanum = true))

example : Spec.pre { username := "salesperson", password := "password123", email := "salesperson@example.com", cookie := none } ∧ Spec.post { username := "salesperson", password := "password123", email := "salesperson@example.com", cookie := none } { loggedIn := true, cookie := some "1234567890" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  cookie   : Option String
  email : String
  password : String
  deriving DecidableEq, Repr

def LoginContract : Contract Input Mid where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i m => ((m.cookie.isSome → m.cookie.getD "" ≠ "") ∧
                     (m.cookie.isNone → i.email.toList.any (· = ' '))) ∧ m.email = i.email ∧ m.password = i.password

def ApplyCookieContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.loggedIn = true ↔
    (o.cookie.isSome → o.cookie.getD "" ≠ "") ∧
    (o.cookie.isNone → m.email.toList.any (· = ' '))) ∧
    (o.loggedIn = false → o.cookie = m.cookie ∧
    (m.cookie.isNone → o.loggedIn = false ∧
    o.cookie = m.cookie ∧
    m.email.toList.any (· = ' ') = true ∧
    m.password.toList.all Char.isAlphanum = true))



theorem po1 : Contract.Compatible LoginContract ApplyCookieContract := by
  discharge_po1 [LoginContract, ApplyCookieContract, Spec]

theorem po2 : Contract.Refines (LoginContract.seq ApplyCookieContract) Spec := by
  discharge_po2 [LoginContract, ApplyCookieContract, Spec]

-- L2 LoginContract (success=False)

def LoginContractImpl (x : Input) : Mid :=
  { cookie := if x.email.toList.any (· = ' ') then some "" else none,
    email := x.email,
    password := x.password }

-- L2 ApplyCookieContract (success=False)

def ApplyCookieContractImpl (x : Mid) : Output :=
  { loggedIn := decide (x.cookie.isSome → x.cookie.getD "" ≠ ""),
    cookie := x.cookie }
