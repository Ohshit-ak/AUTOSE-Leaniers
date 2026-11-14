import ContractForge
open ContractForge

-- 3.5.4/I2: The method of upgrading the system to add capabilities and performance. Areas where upgrades are anticipated should be identified with an estimate of the required effort and resources.

-- L0 spec

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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  upgradedCapabilities : Nat
  upgradedPerformance  : Nat
  currentCapabilities : Nat
  currentPerformance : Nat
  estimatedEffort : Nat
  deriving DecidableEq, Repr

def ComputeUpgradesContract : Contract Input Mid where
  pre  := fun i => i.currentCapabilities ≥ 1 ∧ i.currentPerformance ≥ 1 ∧
                  i.estimatedEffort ≥ 1 ∧ i.estimatedResources ≥ 1
  post := fun i m => (m.upgradedCapabilities = i.currentCapabilities + 1 ∧
                     m.upgradedPerformance = i.currentPerformance + 1) ∧ m.currentCapabilities = i.currentCapabilities ∧ m.currentPerformance = i.currentPerformance ∧ m.estimatedEffort = i.estimatedEffort

def ApplyUpgradesContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.upgradedCapabilities = m.upgradedCapabilities ∧
                     o.upgradedPerformance = m.upgradedPerformance ∧
                     (m.upgradedCapabilities = m.currentCapabilities ∧
                      m.upgradedPerformance = m.currentPerformance →
                      (m.estimatedEffort = 0 → o.upgradedCapabilities = m.currentCapabilities ∧
                       o.upgradedPerformance = m.currentPerformance))



theorem po1 : Contract.Compatible ComputeUpgradesContract ApplyUpgradesContract := by
  discharge_po1 [ComputeUpgradesContract, ApplyUpgradesContract, Spec]

theorem po2 : Contract.Refines (ComputeUpgradesContract.seq ApplyUpgradesContract) Spec := by
  discharge_po2 [ComputeUpgradesContract, ApplyUpgradesContract, Spec]

-- L2 ComputeUpgradesContract (success=True)

def ComputeUpgradesContractImpl (x : Input) : Mid :=
  { upgradedCapabilities := x.currentCapabilities + 1,
    upgradedPerformance := x.currentPerformance + 1,
    currentCapabilities := x.currentCapabilities,
    currentPerformance := x.currentPerformance,
    estimatedEffort := x.estimatedEffort }

theorem ComputeUpgradesContractImpl_ok : ComputeUpgradesContract.Satisfies ComputeUpgradesContractImpl := by
  discharge_po3 [ComputeUpgradesContract, ComputeUpgradesContractImpl]

-- L2 ApplyUpgradesContract (success=True)

def ApplyUpgradesContractImpl (x : Mid) : Output :=
  { upgradedCapabilities := x.upgradedCapabilities,
    upgradedPerformance := x.upgradedPerformance }

theorem ApplyUpgradesContractImpl_ok : ApplyUpgradesContract.Satisfies ApplyUpgradesContractImpl := by
  discharge_po3 [ApplyUpgradesContract, ApplyUpgradesContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ApplyUpgradesContractImpl ∘ ComputeUpgradesContractImpl) :=
  Contract.system_sound po1 po2 ComputeUpgradesContractImpl_ok ApplyUpgradesContractImpl_ok
