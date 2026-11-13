import ContractForge
open ContractForge

-- 4.14.2/S2: The Qualification Methods applied to the software shall include test, demonstration, analysis, and inspection (T, D, A, I).
-- compiles: True · rejects_bad_example: True · checked: True

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
