import ContractForge
open ContractForge

-- 4.14.2/S2: The Qualification Methods applied to the software shall include test, demonstration, analysis, and inspection (T, D, A, I).

-- L0 spec

-- IMPL: T, D, A, I

structure Input where
  testResults : List String
  demonstrations : List String
  analyses : List String
  inspections : List String
  deriving DecidableEq, Repr

structure Output where
  qualified : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.testResults ≠ [] ∧ i.demonstrations ≠ [] ∧ i.analyses ≠ [] ∧ i.inspections ≠ []
  post := fun i o => o.qualified = true ↔
    (i.testResults.all (fun s => s = "passed") ∧
     i.demonstrations.all (fun s => s = "successful") ∧
     i.analyses.all (fun s => s = "valid") ∧
     i.inspections.all (fun s => s = "compliant"))

example : Spec.pre { testResults := ["passed", "passed"], demonstrations := ["successful", "successful"],
                     analyses := ["valid", "valid"], inspections := ["compliant", "compliant"] } ∧
          Spec.post { testResults := ["passed", "passed"], demonstrations := ["successful", "successful"],
                      analyses := ["valid", "valid"], inspections := ["compliant", "compliant"] }
                    { qualified := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { qualified := decide (x.testResults.all (fun s => s = "passed") ∧
                         x.demonstrations.all (fun s => s = "successful") ∧
                         x.analyses.all (fun s => s = "valid") ∧
                         x.inspections.all (fun s => s = "compliant")) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
