import ContractForge
open ContractForge

-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.

-- L0 spec

structure CreditCard where
  number : String
  expMonth : Nat
  expYear : Nat
  cvv : Nat
  deriving DecidableEq, Repr

structure Input where
  creditCard : Option CreditCard
  failedAttempts : Nat
  validationPassed : Bool
  deriving DecidableEq, Repr

structure Output where
  creditCard : Option CreditCard
  failedAttempts : Nat
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.creditCard ≠ none
  post := fun i o => (o.accepted = true ↔ i.validationPassed) ∧
                     o.creditCard = i.creditCard ∧
                     o.failedAttempts = i.failedAttempts + 1

example : Spec.pre { creditCard := some { number := "1234567890123456", expMonth := 12, expYear := 23, cvv := 123 },
                     failedAttempts := 0, validationPassed := true } ∧
          Spec.post { creditCard := some { number := "1234567890123456", expMonth := 12, expYear := 23, cvv := 123 },
                      failedAttempts := 0, validationPassed := true }
                    { creditCard := some { number := "1234567890123456", expMonth := 12, expYear := 23, cvv := 123 },
                      failedAttempts := 1, accepted := true } := by
  unfold Spec; decide

example : Spec.pre { creditCard := some { number := "1234567890123456", expMonth := 12, expYear := 23, cvv := 123 },
                     failedAttempts := 0, validationPassed := false } ∧
          Spec.post { creditCard := some { number := "1234567890123456", expMonth := 12, expYear := 23, cvv := 123 },
                      failedAttempts := 0, validationPassed := false }
                    { creditCard := some { number := "1234567890123456", expMonth := 12, expYear := 23, cvv := 123 },
                      failedAttempts := 1, accepted := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { creditCard := x.creditCard,
    failedAttempts := x.failedAttempts + 1,
    accepted := decide (x.validationPassed) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
