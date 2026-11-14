import ContractForge
open ContractForge

-- 4.4.2/S1: The piloting phase of the Italian VCD service will include the technical actions identified by the implementation plan and some interfacing events to reach selected stakeholders and define through their input the driving conditions for the VCD setup.

-- L0 spec

structure Input where
  actions : List String
  stakeholders : List String
  deriving DecidableEq, Repr

structure Output where
  drivingConditions : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.actions.Nodup ∧ i.stakeholders.Nodup
  post := fun i o => 
    (∀ c ∈ o.drivingConditions, ∃ a ∈ i.actions, ∃ s ∈ i.stakeholders, c = a ++ " " ++ s) ∧
    o.drivingConditions.Nodup ∧
    o.drivingConditions.length = i.actions.length * i.stakeholders.length

example : Spec.pre { actions := ["Action1", "Action2"], stakeholders := ["StakeholderA", "StakeholderB"] } ∧
          Spec.post { actions := ["Action1", "Action2"], stakeholders := ["StakeholderA", "StakeholderB"] }
                    { drivingConditions := ["Action1 StakeholderA", "Action1 StakeholderB", "Action2 StakeholderA", "Action2 StakeholderB"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { drivingConditions := (x.actions.map fun a => x.stakeholders.map fun s => a ++ " " ++ s).flatten }
