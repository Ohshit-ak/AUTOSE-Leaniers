import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.

-- L0 spec

structure Input where
  queryFrom : String
  queryType : String
  deriving DecidableEq, Repr

structure Output where
  emailSent : Bool
  emailTo   : String
  emailBody : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryType = "technical"
  post := fun i o => o.emailSent = true ∧
                     o.emailTo = "admin@example.com" ∧
                     o.emailBody = "Query from: " ++ i.queryFrom ++ " Type: " ++ i.queryType

example : Spec.pre { queryFrom := "customer@example.com", queryType := "technical" } ∧
          Spec.post { queryFrom := "customer@example.com", queryType := "technical" }
                    { emailSent := true, emailTo := "admin@example.com", emailBody := "Query from: customer@example.com Type: technical" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { emailSent := true,
    emailTo := "admin@example.com",
    emailBody := "Query from: " ++ x.queryFrom ++ " Type: " ++ x.queryType }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
