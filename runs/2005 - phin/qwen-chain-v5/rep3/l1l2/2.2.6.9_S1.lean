import ContractForge
open ContractForge

-- 2.2.6.9/S1: Systems supporting OM must be able to store laboratory result(s) and link the result(s) to the original laboratory test request.

-- L0 spec

structure TestRequest where
  specimenId : Nat
  testType   : String
  results    : List String
  deriving DecidableEq, Repr

structure Input where
  specimenId : Nat
  testType   : String
  results    : List String
  deriving DecidableEq, Repr

structure Output where
  specimenId : Nat
  testType   : String
  results    : List String
  linked     : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.specimenId ≠ 0 ∧ i.results.length > 0
  post := fun i o => o.specimenId = i.specimenId ∧
                     o.testType = i.testType ∧
                     o.results = i.results ∧
                     o.linked = true

example : Spec.pre { specimenId := 123, testType := "PCR", results := ["positive"] } ∧
          Spec.post { specimenId := 123, testType := "PCR", results := ["positive"] }
                    { specimenId := 123, testType := "PCR", results := ["positive"], linked := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { specimenId := x.specimenId,
    testType := x.testType,
    results := x.results,
    linked := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
