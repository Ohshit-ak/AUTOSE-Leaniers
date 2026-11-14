import ContractForge
open ContractForge

-- 2.5.2.4/S1: The system shall send a notification email to a Client Services email distribution list if the user is directed to the xxx error page.

-- L0 spec

structure Input where
  userRedirected : Bool
  errorPage      : String
  clientsEmail   : String
  deriving DecidableEq, Repr

structure Output where
  notificationSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.userRedirected = true ∧ i.errorPage = "xxx"
  post := fun i o => o.notificationSent = true ∧
                     (o.notificationSent = i.userRedirected ∧
                      (o.notificationSent = true ↔ i.userRedirected = true))

example : Spec.pre { userRedirected := true, errorPage := "xxx", clientsEmail := "cs@example.com" } ∧
          Spec.post { userRedirected := true, errorPage := "xxx", clientsEmail := "cs@example.com" }
                    { notificationSent := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { notificationSent := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
