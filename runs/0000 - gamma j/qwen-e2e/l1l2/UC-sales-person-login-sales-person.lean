import ContractForge
open ContractForge

-- UC-sales-person-login-sales-person: Login Sales Person: Login to an account with the system.

-- L0 spec

structure Input where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Output where
  loggedIn : Bool
  cookie   : Option String
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => o.loggedIn = true ↔
    (i.username = "registered_username" ∧ i.password = "registered_password") ∧
    (o.cookie = some "session_cookie" ↔ i.username = "registered_username") ∧
    (o.emailSent = true ↔ i.password ≠ "registered_password")

example : Spec.pre { username := "registered_username", password := "registered_password", email := "registered_email" } ∧
          Spec.post { username := "registered_username", password := "registered_password", email := "registered_email" }
                    { loggedIn := true, cookie := some "session_cookie", emailSent := false } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Output where
  loggedIn : Bool
  cookie   : Option String
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => o.loggedIn = true ↔
    (i.username = "registered_username" ∧ i.password = "registered_password") ∧
    (o.cookie = some "session_cookie" ↔ i.username = "registered_username") ∧
    (o.emailSent = true ↔ i.password ≠ "registered_password")

-- Component 1: Authentication
def AuthContract : Contract Input (Output × Bool) where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i (o, _) => o.1 loggedIn = true ↔
    (i.username = "registered_username" ∧ i.password = "registered_password") ∧
    (o.2 = true ↔ i.username = "registered_username")

-- Component 2: Cookie Generation
def CookieGenContract : Contract (Output × Bool) Output where
  pre  := fun (o, _) => o.1 loggedIn = true
  post := fun (o, _) o' => o'.cookie = some "session_cookie" ↔ o.2 = true

-- Component 3: Email Sending
def EmailSendContract : Contract Output Output where
  pre  := fun o => o.loggedIn = true
  post := fun o o' => o'.emailSent = true ↔ o.password ≠ "registered_password"

-- Prove PO1: Each component's assumption follows from its predecessor's guarantee
theorem AuthCompatible : Contract.Compatible AuthContract Spec := by
  unfold AuthContract Spec; discharge_po

theorem CookieGenCompatible : Contract.Compatible CookieGenContract AuthContract := by
  unfold CookieGenContract AuthContract; discharge_po

theorem EmailSendCompatible : Contract.Compatible EmailSendContract CookieGenContract := by
  unfold EmailSendContract CookieGenContract; discharge_po

-- Prove PO2: The composition refines the spec
theorem AuthRefines : Contract.Refines (AuthContract.seq CookieGenContract) Spec := by
  unfold AuthContract CookieGenContract Spec; discharge_po

theorem CookieGenRefines : Contract.Refines (CookieGenContract.seq EmailSendContract) (AuthContract.seq CookieGenContract) := by
  unfold CookieGenContract EmailSendContract AuthContract; discharge_po

theorem SpecRefines : Contract.Refines (EmailSendContract.seq (CookieGenContract.seq AuthContract)) Spec := by
  unfold EmailSendContract CookieGenContract AuthContract Spec; discharge_po