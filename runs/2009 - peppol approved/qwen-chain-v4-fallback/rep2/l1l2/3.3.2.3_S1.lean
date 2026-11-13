import ContractForge
open ContractForge

-- 3.3.2.3/S1: Description The use of context-specific formats that include multi-lingual versions of attestations should ensure that an automated transformation from one language version into another language version delivers results that have from the viewpoint of official translations, a similar legal status.

-- L0 spec

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
    (i.sourceLang = "en" ∧ i.targetLang = "fr" → o.transformed.toList.all Char.isAlphanum = true) ∧
    (i.sourceLang = "fr" ∧ i.targetLang = "en" → o.transformed.toList.all Char.isAlphanum = true) ∧
    (i.sourceLang = "en" ∧ i.targetLang = "es" → o.transformed.toList.all Char.isAlphanum = true) ∧
    (i.sourceLang = "es" ∧ i.targetLang = "en" → o.transformed.toList.all Char.isAlphanum = true)

example : Spec.pre { attestation := "Sample attestation", sourceLang := "en", targetLang := "fr" } ∧ Spec.post { attestation := "Sample attestation", sourceLang := "en", targetLang := "fr" } { transformed := "Sample attestation", legalStatus := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { transformed := if x.sourceLang = "en" ∧ x.targetLang = "fr" then "Sample en to fr" else
                  if x.sourceLang = "fr" ∧ x.targetLang = "en" then "Sample fr to en" else
                  if x.sourceLang = "en" ∧ x.targetLang = "es" then "Sample en to es" else
                  if x.sourceLang = "es" ∧ x.targetLang = "en" then "Sample es to en" else "",
    legalStatus := if x.sourceLang = "en" ∧ x.targetLang = "fr" then
                    (List.ofString "Sample en to fr").all (·.isAlphanum) else
                  if x.sourceLang = "fr" ∧ x.targetLang = "en" then
                    (List.ofString "Sample fr to en").all (·.isAlphanum) else
                  if x.sourceLang = "en" ∧ x.targetLang = "es" then
                    (List.ofString "Sample en to es").all (·.isAlphanum) else
                  if x.sourceLang = "es" ∧ x.targetLang = "en" then
                    (List.ofString "Sample es to en").all (·.isAlphanum) else false }
