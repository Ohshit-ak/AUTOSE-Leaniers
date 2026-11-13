import ContractForge
open ContractForge

-- 5/S6: The core services, support layer and security and access control components can be deployed as standard components with necessary configuration changes.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  coreServices   : List String
  supportLayer   : List String
  securityAccess : List String
  configChanges  : List String
  deriving DecidableEq, Repr

structure Output where
  deployedComponents : List String
  configChanges      : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.coreServices.Nodup ∧ i.supportLayer.Nodup ∧ i.securityAccess.Nodup ∧ i.configChanges.Nodup
  post := fun i o => o.deployedComponents = i.coreServices ++ i.supportLayer ++ i.securityAccess ∧
                      o.configChanges = i.configChanges

example : Spec.pre { coreServices := ["service1", "service2"], supportLayer := ["layer1", "layer2"], securityAccess := ["sec1", "sec2"], configChanges := ["change1", "change2"] } ∧
          Spec.post { coreServices := ["service1", "service2"], supportLayer := ["layer1", "layer2"], securityAccess := ["sec1", "sec2"], configChanges := ["change1", "change2"] }
                    { deployedComponents := ["service1", "service2", "layer1", "layer2", "sec1", "sec2"], configChanges := ["change1", "change2"] } := by
  unfold Spec; decide
