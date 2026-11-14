import ContractForge
open ContractForge

-- 5/S7: The customization layer can override and add to the core services based on the specific state requirements and can be plugged with the core services.
-- compiles: True · rejects_bad_example: True · checked: True

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
