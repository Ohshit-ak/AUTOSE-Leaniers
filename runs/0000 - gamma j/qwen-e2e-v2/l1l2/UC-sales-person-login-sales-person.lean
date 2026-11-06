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

structure Mid where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i m => m.username = i.username ∧ m.password = i.password ∧ m.email = i.email

def AuthenticateContract : Contract Mid Output where
  pre  := fun m => m.username = "registered_username" ∧ m.password = "registered_password"
  post := fun m o => o.loggedIn = true ∧
    (o.cookie = some "session_cookie" ↔ m.username = "registered_username") ∧
    (o.emailSent = true ↔ m.password ≠ "registered_password")

theorem po1 : Contract.Compatible ValidateContract AuthenticateContract := by
  unfold Contract.Compatible ValidateContract AuthenticateContract
  intro i m _ h
  exact h.2.2

theorem po2 : Contract.Refines (ValidateContract.seq AuthenticateContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract AuthenticateContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]