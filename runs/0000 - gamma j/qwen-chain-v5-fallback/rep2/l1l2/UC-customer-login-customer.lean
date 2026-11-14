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

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { loggedIn := decide (x.username = "registeredUsername" ∧ x.password = "registeredPassword" ∧ x.email = "registeredEmail"),
    cookie := if x.username = "incorrectUsername" ∧ x.password = "incorrectPassword" ∧ x.email = "registeredEmail" then some "cookieValue" else none }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
