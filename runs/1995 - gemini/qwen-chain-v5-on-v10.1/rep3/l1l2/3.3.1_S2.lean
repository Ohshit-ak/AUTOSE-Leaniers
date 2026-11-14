import ContractForge
open ContractForge

-- 3.3.1/S2: Given the large number of instruments, there can be many different stations which are active at the same time.

-- L0 spec

structure Input where
  activeStations : List String
  deriving DecidableEq, Repr

structure Output where
  activeStations : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.activeStations.Nodup
  post := fun i o => o.activeStations = i.activeStations

example : Spec.pre { activeStations := ["Station1", "Station2"] } ∧
          Spec.post { activeStations := ["Station1", "Station2"] }
                    { activeStations := ["Station1", "Station2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { activeStations := x.activeStations }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
