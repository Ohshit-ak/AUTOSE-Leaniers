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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { loggedIn := x.username ≠ "" ∧ x.password ≠ "" ∧ x.email ≠ "", cookie := if x.username ≠ "" ∧ x.password ≠ "" ∧ x.email ≠ "" then some (x.email) else none }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
