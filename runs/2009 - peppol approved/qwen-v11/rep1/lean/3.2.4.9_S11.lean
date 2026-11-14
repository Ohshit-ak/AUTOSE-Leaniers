import ContractForge
open ContractForge

-- 3.2.4.9/S11: Instead such an attestation can be included into VCD stages 3 and 4 if it is sufficiently described through context specific data in multilingual versions (e.g.
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  attestation : String
  contextData : List String
  language : String
  deriving DecidableEq, Repr

structure Output where
  included : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.language ≠ "" ∧ i.contextData ≠ []
  post := fun i o => o.included = true ↔
    (i.language = "en" ∧ i.contextData.all (fun c => c.length ≤ 100)) ∨
    (i.language = "fr" ∧ i.contextData.all (fun c => c.length ≤ 100)) ∨
    (i.language = "de" ∧ i.contextData.all (fun c => c.length ≤ 100))

example : Spec.pre { attestation := "Sample attestation", contextData := ["Data 1", "Data 2"], language := "en" } ∧
          Spec.post { attestation := "Sample attestation", contextData := ["Data 1", "Data 2"], language := "en" }
                    { included := true } := by
  unfold Spec; decide
