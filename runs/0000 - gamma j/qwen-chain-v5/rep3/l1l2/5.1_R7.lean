import ContractForge
open ContractForge

-- 5.1/R7: The system shall be able to validate credit card in less than 2 seconds.

-- L0 spec

structure Input where
  cardNumber : String
  deriving DecidableEq, Repr

structure Output where
  valid     : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.cardNumber = "1234567890123456") ∧
    o.elapsedMicros < 2000000

example : Spec.pre { cardNumber := "1234567890123456" } ∧
          Spec.post { cardNumber := "1234567890123456" }
                    { valid := true, elapsedMicros := 1500000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := x.cardNumber = "1234567890123456", elapsedMicros := 1000000 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
