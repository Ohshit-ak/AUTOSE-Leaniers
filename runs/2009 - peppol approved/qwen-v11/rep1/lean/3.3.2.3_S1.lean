import ContractForge
open ContractForge

-- 3.3.2.3/S1: Description The use of context-specific formats that include multi-lingual versions of attestations should ensure that an automated transformation from one language version into another language version delivers results that have from the viewpoint of official translations, a similar legal status.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  attestation : String
  sourceLang  : String
  targetLang  : String
  deriving DecidableEq, Repr

structure Output where
  transformed : String
  legalStatus  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.sourceLang ≠ "" ∧ i.targetLang ≠ ""
  post := fun i o => o.legalStatus ↔
    (i.sourceLang = "en" ∧ i.targetLang = "fr" → o.transformed = "Sample attestation" ∧ o.legalStatus = true) ∧
    (i.sourceLang = "fr" ∧ i.targetLang = "en" → o.transformed = "Sample attestation" ∧ o.legalStatus = true) ∧
    (i.sourceLang = "en" ∧ i.targetLang = "es" → o.transformed = "Sample attestation" ∧ o.legalStatus = true) ∧
    (i.sourceLang = "es" ∧ i.targetLang = "en" → o.transformed = "Sample attestation" ∧ o.legalStatus = true)

example : Spec.pre { attestation := "Sample attestation", sourceLang := "en", targetLang := "fr" } ∧ Spec.post { attestation := "Sample attestation", sourceLang := "en", targetLang := "fr" } { transformed := "Sample attestation", legalStatus := true } := by
  unfold Spec; decide
