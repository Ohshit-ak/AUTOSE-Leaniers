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
  post := fun i o => o.geographicalSpread = (i.pilotImplementations.length ≥ 8) ∧
                     o.proofOfConcept = (i.europeanServiceProvider = true)

example : Spec.pre { pilotImplementations := ["impl1", "impl2", "impl3", "impl4", "impl5", "impl6", "impl7", "impl8"], europeanServiceProvider := true } ∧
          Spec.post { pilotImplementations := ["impl1", "impl2", "impl3", "impl4", "impl5", "impl6", "impl7", "impl8"], europeanServiceProvider := true }
                    { geographicalSpread := true, proofOfConcept := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { geographicalSpread := x.pilotImplementations.length ≥ 8,
    proofOfConcept := x.europeanServiceProvider = true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
