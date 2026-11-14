import ContractForge
open ContractForge

-- 3.14.1/S1: The user can select between a number of translations that are available at KeePass website.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { selected := x.selected,
    available := x.translations }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
