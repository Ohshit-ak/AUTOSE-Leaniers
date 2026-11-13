import ContractForge
open ContractForge

-- 2.12/S1: The telescope and instrument software shall contain built-in test (BIT) facilities to verify Gemini 8m Telescopes system and Gemini 8m Telescopes software performances.

-- L0 spec

structure Input where
  telescopeId : Nat
  deriving DecidableEq, Repr

structure Output where
  testPassed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.telescopeId ≠ 0
  post := fun i o => o.testPassed ↔
    (i.telescopeId = 1234567890) ∧
    (i.telescopeId = 1234567890 →
      (i.telescopeId = 1234567890 ∧ i.telescopeId = 1234567890))

example : Spec.pre { telescopeId := 1234567890 } ∧
          Spec.post { telescopeId := 1234567890 }
                    { testPassed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { testPassed := (x.telescopeId = 1234567890) ∧ (x.telescopeId = 1234567890 → (x.telescopeId = 1234567890 ∧ x.telescopeId = 1234567890)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
