import ContractForge
open ContractForge

-- 3.14.1/S6: Doing this he will be transferred at KeePass website and choose the language he wants for downloading.
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  language : String
  deriving DecidableEq, Repr

structure Output where
  redirected : Bool
  languageChosen : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.language.length > 0
  post := fun i o =>
    (o.redirected = true ↔
      i.language = "en" ∨ i.language = "de" ∨ i.language = "fr" ∨ i.language = "es" ∨
      i.language = "it" ∨ i.language = "ru" ∨ i.language = "zh") ∧
    o.languageChosen = true ↔
    (o.redirected = true ∧
     (i.language = "en" → o.languageChosen = (o.languageChosen = true)) ∧
     (i.language = "de" → o.languageChosen = (o.languageChosen = true)) ∧
     (i.language = "fr" → o.languageChosen = (o.languageChosen = true)) ∧
     (i.language = "es" → o.languageChosen = (o.languageChosen = true)) ∧
     (i.language = "it" → o.languageChosen = (o.languageChosen = true)) ∧
     (i.language = "ru" → o.languageChosen = (o.languageChosen = true)) ∧
     (i.language = "zh" → o.languageChosen = (o.languageChosen = true)))

example : Spec.pre { language := "en" } ∧
          Spec.post { language := "en" } { redirected := true, languageChosen := true } := by
  unfold Spec; decide
