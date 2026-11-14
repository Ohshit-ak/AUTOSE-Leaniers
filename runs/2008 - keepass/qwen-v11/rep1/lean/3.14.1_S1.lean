import ContractForge
open ContractForge

-- 3.14.1/S1: The user can select between a number of translations that are available at KeePass website.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  translations : List String
  selected     : String
  deriving DecidableEq, Repr

structure Output where
  selected     : String
  available    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selected ∈ i.translations
  post := fun i o => o.selected = i.selected ∧
                     (o.available = true ↔ i.translations.length > 0)

example : Spec.pre { translations := ["en", "fr", "de"], selected := "en" } ∧
          Spec.post { translations := ["en", "fr", "de"], selected := "en" }
                    { selected := "en", available := true } := by
  unfold Spec; decide
