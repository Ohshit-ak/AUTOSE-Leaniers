import ContractForge
open ContractForge

-- 4.3.1/S2: EPICS consists of a set of hardware and software components from which a control system can be created.

-- L0 spec

structure Input where
  components : List String
  deriving DecidableEq, Repr

structure Output where
  controlSystem : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.components.Nodup
  post := fun i o => o.controlSystem.Nodup ∧
                     o.controlSystem.length ≤ i.components.length ∧
                     (∀ c ∈ o.controlSystem, c ∈ i.components) ∧
                     (o.controlSystem = i.components)

example : Spec.pre { components := ["HMI", "PLC", "DAQ"] } ∧
          Spec.post { components := ["HMI", "PLC", "DAQ"] }
                    { controlSystem := ["HMI", "PLC", "DAQ"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { controlSystem := x.components
  }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
