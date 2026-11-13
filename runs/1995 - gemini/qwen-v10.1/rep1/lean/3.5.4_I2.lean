import ContractForge
open ContractForge

-- 3.5.4/I2: The method of upgrading the system to add capabilities and performance. Areas where upgrades are anticipated should be identified with an estimate of the required effort and resources.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  currentCapabilities : Nat
  currentPerformance  : Nat
  upgradeAreas        : List String
  estimatedEffort     : List Nat
  estimatedResources  : List String
  deriving DecidableEq, Repr

structure Output where
  upgradedCapabilities : Nat
  upgradedPerformance  : Nat
  upgradeAreas         : List String
  estimatedEffort      : List Nat
  estimatedResources   : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.upgradeAreas.Nodup
  post := fun i o => o.upgradeAreas = i.upgradeAreas ∧
                     o.estimatedEffort = i.estimatedEffort ∧
                     o.estimatedResources = i.estimatedResources ∧
                     (o.upgradedCapabilities = i.currentCapabilities + 1 ∧
                      o.upgradedPerformance = i.currentPerformance + 1) ∨
                     (o.upgradedCapabilities = i.currentCapabilities ∧
                      o.upgradedPerformance = i.currentPerformance)

example : Spec.pre { currentCapabilities := 5, currentPerformance := 10,
                     upgradeAreas := ["API", "UI"], estimatedEffort := [20, 30],
                     estimatedResources := ["dev1", "dev2"] } ∧
          Spec.post { currentCapabilities := 5, currentPerformance := 10,
                      upgradeAreas := ["API", "UI"], estimatedEffort := [20, 30],
                      estimatedResources := ["dev1", "dev2"] }
                    { upgradedCapabilities := 6, upgradedPerformance := 11,
                      upgradeAreas := ["API", "UI"], estimatedEffort := [20, 30],
                      estimatedResources := ["dev1", "dev2"] } := by
  unfold Spec; decide
