import ContractForge
open ContractForge

-- 4.2/S9: With a total of eight pilot implementations plus the European Service Provider implementation of the pre-VCD mapping tool, the WP 2 will reach a wide geographical spread as well as a profound proof of the overall VCD concept.

-- L0 spec

structure Input where
  pilotImplementations : List String
  europeanServiceProvider : Bool
  deriving DecidableEq, Repr

structure Output where
  geographicalSpread : Bool
  proofOfConcept : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.pilotImplementations.length = 8 ∧ i.europeanServiceProvider
  post := fun i o => (o.geographicalSpread = true ↔
    i.pilotImplementations.contains "EU" ∨
    i.pilotImplementations.contains "US" ∨
    i.pilotImplementations.contains "ASIA" ∨
    i.pilotImplementations.contains "AFRICA" ∨
    i.pilotImplementations.contains "AUSTRALIA" ∨
    i.pilotImplementations.contains "LATAM" ∨
    i.pilotImplementations.contains "MIDDLE_EAST" ∨
    i.pilotImplementations.contains "OTHER_REGION") ∧
    (o.proofOfConcept = true ↔
    i.pilotImplementations.length ≥ 1)

example : Spec.pre { pilotImplementations := ["EU", "US", "ASIA", "AFRICA", "AUSTRALIA", "LATAM", "MIDDLE_EAST", "OTHER_REGION"], europeanServiceProvider := true } ∧
          Spec.post { pilotImplementations := ["EU", "US", "ASIA", "AFRICA", "AUSTRALIA", "LATAM", "MIDDLE_EAST", "OTHER_REGION"], europeanServiceProvider := true }
                    { geographicalSpread := true, proofOfConcept := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { geographicalSpread := decide (x.pilotImplementations.contains "EU" ∨
                                   x.pilotImplementations.contains "US" ∨
                                   x.pilotImplementations.contains "ASIA" ∨
                                   x.pilotImplementations.contains "AFRICA" ∨
                                   x.pilotImplementations.contains "AUSTRALIA" ∨
                                   x.pilotImplementations.contains "LATAM" ∨
                                   x.pilotImplementations.contains "MIDDLE_EAST" ∨
                                   x.pilotImplementations.contains "OTHER_REGION"),
    proofOfConcept := decide (x.pilotImplementations.length ≥ 1) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
