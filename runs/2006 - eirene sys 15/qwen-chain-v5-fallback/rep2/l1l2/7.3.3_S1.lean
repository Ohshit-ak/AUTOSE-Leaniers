import ContractForge
open ContractForge

-- 7.3.3/S1: It shall be possible to register and deregister a functional number by the user entering his functional number, which is transmitted to the ground along with the subscriber's IMSI, using USSD (see section 11).

-- L0 spec

structure FunctionalNumber where
  number : String
  deriving DecidableEq, Repr

structure Input where
  functionalNumber : String
  subscriberIMSI   : String
  deregister      : Bool
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  message    : String
  deriving DecidableEq, Repr

-- A functional number is valid if it consists of exactly 10 digits
def ValidFunctionalNumber (fn : String) : Bool :=
  fn.length = 10 ∧ fn.toList.all Char.isDigit = true

def Spec : Contract Input Output where
  pre  := fun i => ValidFunctionalNumber i.functionalNumber
  post := fun i o =>
    (o.registered = true ↔
      (i.deregister = false →
        -- If not deregistering, the functional number is registered
        true
      ) ∧
      -- If deregistering, the functional number is unregistered
      (i.deregister = true →
        false
      )
    ) ∧
    (o.message = "Functional number registered." ↔ o.registered = true) ∧
    (o.message = "Functional number deregistered." ↔ o.registered = false)

example : Spec.pre { functionalNumber := "1234567890", subscriberIMSI := "IMSI123456789012345", deregister := false } ∧
          Spec.post { functionalNumber := "1234567890", subscriberIMSI := "IMSI123456789012345", deregister := false }
                    { registered := true, message := "Functional number registered." } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { registered := decide ((x.deregister = false →
      true
    ) ∧
    
    (x.deregister = true →
      false
    )),
    message := if x.deregister then "Functional number deregistered." else "Functional number registered." }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
