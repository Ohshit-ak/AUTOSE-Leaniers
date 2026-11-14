import ContractForge
open ContractForge

-- UC-customer-login-customer: Login Customer: Login to a customer account with the system.

-- L0 spec

structure Input where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Output where
  loggedIn : Bool
  cookie   : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => (o.loggedIn = true ↔
    i.username = "registeredUsername" ∧ i.password = "registeredPassword" ∧
    i.email = "registeredEmail") ∧
    (o.loggedIn = false →
      (o.cookie = some "cookieValue" ↔ i.username = "incorrectUsername" ∧
       i.password = "incorrectPassword" ∧ i.email = "registeredEmail"))

example : Spec.pre { username := "registeredUsername", password := "registeredPassword", email := "registeredEmail" } ∧
          Spec.post { username := "registeredUsername", password := "registeredPassword", email := "registeredEmail" }
                    { loggedIn := true, cookie := some "cookieValue" } := by
  unfold Spec; decide

example : Spec.pre { username := "incorrectUsername", password := "incorrectPassword", email := "registeredEmail" } ∧
          Spec.post { username := "incorrectUsername", password := "incorrectPassword", email := "registeredEmail" }
                    { loggedIn := false, cookie := some "cookieValue" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  loggedIn : Bool
  cookie   : Option String
  username : String
  password : String
  email : String
  deriving DecidableEq, Repr

def AuthenticationContract : Contract Input Mid where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i m => ((m.loggedIn = true ↔
    i.username = "registeredUsername" ∧ i.password = "registeredPassword" ∧
    i.email = "registeredEmail")) ∧ m.username = i.username ∧ m.password = i.password ∧ m.email = i.email

def CookieAssignmentContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => (o.loggedIn = m.loggedIn) ∧
                     (o.cookie = some "cookieValue" ↔
                      m.username = "incorrectUsername" ∧
                      m.password = "incorrectPassword" ∧
                      m.email = "registeredEmail")



theorem po1 : Contract.Compatible AuthenticationContract CookieAssignmentContract := by
  discharge_po1 [AuthenticationContract, CookieAssignmentContract, Spec]

theorem po2 : Contract.Refines (AuthenticationContract.seq CookieAssignmentContract) Spec := by
  discharge_po2 [AuthenticationContract, CookieAssignmentContract, Spec]

-- L2 AuthenticationContract (success=True)

def AuthenticationContractImpl (x : Input) : Mid :=
  { loggedIn := decide (x.username = "registeredUsername" ∧ x.password = "registeredPassword" ∧
    x.email = "registeredEmail"),
    cookie := none,
    username := x.username,
    password := x.password,
    email := x.email }

theorem AuthenticationContractImpl_ok : AuthenticationContract.Satisfies AuthenticationContractImpl := by
  discharge_po3 [AuthenticationContract, AuthenticationContractImpl]

-- L2 CookieAssignmentContract (success=True)

def CookieAssignmentContractImpl (x : Mid) : Output :=
  { loggedIn := x.loggedIn,
    cookie := if x.username = "incorrectUsername" ∧
                      x.password = "incorrectPassword" ∧
                      x.email = "registeredEmail" then some "cookieValue" else none }

theorem CookieAssignmentContractImpl_ok : CookieAssignmentContract.Satisfies CookieAssignmentContractImpl := by
  discharge_po3 [CookieAssignmentContract, CookieAssignmentContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (CookieAssignmentContractImpl ∘ AuthenticationContractImpl) :=
  Contract.system_sound po1 po2 AuthenticationContractImpl_ok CookieAssignmentContractImpl_ok
