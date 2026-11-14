import ContractForge
open ContractForge

-- UC-sales-person-logout-sales-person: Logout Sales Person: Logout the Sales Person account on the system.

-- L0 spec

structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  cookie : String
  signedIn : Bool
  deriving DecidableEq, Repr

structure Output where
  cookie : String
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = false ∧ o.cookie = i.cookie

example : Spec.pre { cookie := "abc123", signedIn := true } ∧
          Spec.post { cookie := "abc123", signedIn := true }
                    { signedIn := false, cookie := "abc123" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { cookie := x.cookie,
    signedIn := false }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
