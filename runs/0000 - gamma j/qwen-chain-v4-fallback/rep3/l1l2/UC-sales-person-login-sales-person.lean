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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { loggedIn := (x.username = "registered_username" ∧ x.password = "registered_password"),
    cookie := if x.username = "registered_username" ∧ x.password = "registered_password" then some "session_cookie" else none,
    emailSent := x.password ≠ "registered_password" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
