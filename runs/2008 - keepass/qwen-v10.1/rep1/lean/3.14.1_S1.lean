import ContractForge
open ContractForge

-- 3.14.1/S1: The user can select between a number of translations that are available at KeePass website.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  translations : List String
  selected     : String
  deriving DecidableEq, Repr

structure Output where
  selected     : String
  available    : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.selected ∈ i.translations
  post := fun i o => o.selected = i.selected ∧
                     o.available = i.translations

example : Spec.pre { translations := ["en", "fr", "de"], selected := "en" } ∧
          Spec.post { translations := ["en", "fr", "de"], selected := "en" }
                    { selected := "en", available := ["en", "fr", "de"] } := by
  unfold Spec; decide
