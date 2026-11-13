import ContractForge
open ContractForge

-- 5/S7: The customization layer can override and add to the core services based on the specific state requirements and can be plugged with the core services.

-- L0 spec

structure Input where
  coreServices : List String
  customizationLayer : List String
  deriving DecidableEq, Repr

structure Output where
  services : List String
  deriving DecidableEq, Repr

-- An item in the customization layer should not be a duplicate of an item in the core services
def DuplicateInCore (i : Input) (it : String) : Bool :=
  it ∈ i.coreServices

def Spec : Contract Input Output where
  pre  := fun i => i.coreServices.Nodup ∧ i.customizationLayer.Nodup
  post := fun i o => (o.services = i.coreServices ++ i.customizationLayer ↔
    ∀ it ∈ i.customizationLayer, ¬DuplicateInCore i it) ∧
    (if o.services.length > i.coreServices.length + i.customizationLayer.length then
      o.services.any (DuplicateInCore i) else
      True)

example : Spec.pre { coreServices := ["service1", "service2"], customizationLayer := ["service3"] } ∧
          Spec.post { coreServices := ["service1", "service2"], customizationLayer := ["service3"] }
                    { services := ["service1", "service2", "service3"] } := by
  unfold Spec; decide

example : ¬Spec.post { coreServices := ["service1", "service2"], customizationLayer := ["service2", "service3"] }
                    { services := ["service1", "service2", "service2", "service3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { services := x.coreServices ++ x.customizationLayer.filter (fun it => ¬DuplicateInCore x it) }
