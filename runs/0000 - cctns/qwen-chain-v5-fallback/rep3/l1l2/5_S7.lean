import ContractForge
open ContractForge

-- 5/S7: The customization layer can override and add to the core services based on the specific state requirements and can be plugged with the core services.

-- L0 spec

structure Input where
  coreServices : List String
  customizationLayer : List String
  stateRequirements : List String
  deriving DecidableEq, Repr

structure Output where
  services : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.coreServices.Nodup ∧ i.customizationLayer.Nodup ∧ i.stateRequirements.Nodup
  post := fun i o => 
    o.services = i.coreServices ++ i.customizationLayer.filter (fun x => i.stateRequirements.contains x)

example : Spec.pre { coreServices := ["service1", "service2"], customizationLayer := ["service3", "service4"], stateRequirements := ["service3", "service4", "service5"] } ∧
          Spec.post { coreServices := ["service1", "service2"], customizationLayer := ["service3", "service4"], stateRequirements := ["service3", "service4", "service5"] }
                    { services := ["service1", "service2", "service3", "service4"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { services := x.coreServices ++ x.customizationLayer.filter (fun y => x.stateRequirements.contains y) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
