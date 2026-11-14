import ContractForge
open ContractForge

-- 3.3.1/S6: Given the requirement to be able to access the Gemini 8m Telescopes from several points, the user interface should rather be seen as a package to be callable from a large number of stations, depending on where a user is.

-- L0 spec

structure Input where
  station : String
  telescope : String
  deriving DecidableEq, Repr

structure Output where
  accessible : Bool
  telescope : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.station ≠ ""
  post := fun i o => (o.accessible = true ↔
    (o.telescope = "Gemini 8m" ∧
     (i.station = "Station A" ∨ i.station = "Station B" ∨ i.station = "Station C"))) ∧
    (o.accessible = false → o.telescope = i.telescope) ∧
    (o.telescope = "" ↔ o.accessible = false)

example : Spec.pre { station := "Station A", telescope := "Gemini 8m" } ∧
          Spec.post { station := "Station A", telescope := "Gemini 8m" }
                    { accessible := true, telescope := "Gemini 8m" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { accessible := decide (x.station = "Station A" ∨ x.station = "Station B" ∨ x.station = "Station C"),
    telescope := if x.station = "Station A" ∨ x.station = "Station B" ∨ x.station = "Station C" then "Gemini 8m" else x.telescope }
