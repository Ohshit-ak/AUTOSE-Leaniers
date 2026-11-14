import ContractForge
open ContractForge

-- 3.5.4/I2: The method of upgrading the system to add capabilities and performance. Areas where upgrades are anticipated should be identified with an estimate of the required effort and resources.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  currentCapabilities : Nat
  currentPerformance  : Nat
  upgradeAreas        : List String
  estimatedEffort     : Nat
  estimatedResources  : Nat
  deriving DecidableEq, Repr

structure Output where
  upgradedCapabilities : Nat
  upgradedPerformance  : Nat
  deriving DecidableEq, Repr

-- IMPL: Upgrade process

def Spec : Contract Input Output where
  pre  := fun i => i.currentCapabilities ≥ 1 ∧ i.currentPerformance ≥ 1 ∧
                  i.estimatedEffort ≥ 1 ∧ i.estimatedResources ≥ 1
  post := fun i o => o.upgradedCapabilities = i.currentCapabilities + 1 ∧
                     o.upgradedPerformance = i.currentPerformance + 1 ∧
                     (i.estimatedEffort = 0 → o.upgradedCapabilities = i.currentCapabilities ∧
                      o.upgradedPerformance = i.currentPerformance)

example : Spec.pre { currentCapabilities := 5, currentPerformance := 7,
                     upgradeAreas := ["new feature", "improved UI"],
                     estimatedEffort := 10, estimatedResources := 5 } ∧
          Spec.post { currentCapabilities := 5, currentPerformance := 7,
                      upgradeAreas := ["new feature", "improved UI"],
                      estimatedEffort := 10, estimatedResources := 5 }
                    { upgradedCapabilities := 6, upgradedPerformance := 8 } := by
  unfold Spec; decide
