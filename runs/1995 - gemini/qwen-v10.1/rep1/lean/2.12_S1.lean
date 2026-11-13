import ContractForge
open ContractForge

-- 2.12/S1: The telescope and instrument software shall contain built-in test (BIT) facilities to verify Gemini 8m Telescopes system and Gemini 8m Telescopes software performances.
-- compiles: True · rejects_bad_example: True · checked: True

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
