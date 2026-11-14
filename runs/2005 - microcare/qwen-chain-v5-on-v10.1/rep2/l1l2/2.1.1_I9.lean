import ContractForge
open ContractForge

-- 2.1.1/I9: The filed office will validate the claim form manually and through system,

-- L0 spec

structure ClaimForm where
  formNumber : String
  patientName : String
  amount : Nat
  deriving DecidableEq, Repr

structure Input where
  formNumber : String
  patientName : String
  amount : Nat
  isValid : Bool
  deriving DecidableEq, Repr

structure Output where
  isValid : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.formNumber ≠ "" ∧ i.patientName ≠ "" ∧ 0 < i.amount
  post := fun i o => (o.isValid = true ↔ i.isValid) ∧
                     (o.message = "Claim form is valid." ↔ o.isValid = true) ∧
                     (o.message = "Claim form is invalid." ↔ o.isValid = false)

example : Spec.pre { formNumber := "F12345", patientName := "John Doe", amount := 500, isValid := true } ∧
          Spec.post { formNumber := "F12345", patientName := "John Doe", amount := 500, isValid := true }
                    { isValid := true, message := "Claim form is valid." } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { isValid := decide (x.isValid),
    message := if x.isValid then "Claim form is valid." else "Claim form is invalid." }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
