import ContractForge
open ContractForge

-- 3.3.1/S6: Given the requirement to be able to access the Gemini 8m Telescopes from several points, the user interface should rather be seen as a package to be callable from a large number of stations, depending on where a user is.

-- L0 spec

structure Input where
  station : String
  deriving DecidableEq, Repr

structure Output where
  accessible : Bool
  telescope : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.station ≠ ""
  post := fun i o => o.accessible = true ↔
    (o.telescope = "Gemini 8m" ∧
     (i.station = "Station A" ∨ i.station = "Station B" ∨ i.station = "Station C"))

example : Spec.pre { station := "Station A" } ∧
          Spec.post { station := "Station A" }
                    { accessible := true, telescope := "Gemini 8m" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { accessible := x.station = "Station A" ∨ x.station = "Station B" ∨ x.station = "Station C", telescope := "Gemini 8m" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
