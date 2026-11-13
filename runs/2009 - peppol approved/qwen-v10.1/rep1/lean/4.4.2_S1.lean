import ContractForge
open ContractForge

-- 4.4.2/S1: The piloting phase of the Italian VCD service will include the technical actions identified by the implementation plan and some interfacing events to reach selected stakeholders and define through their input the driving conditions for the VCD setup.
-- compiles: True · rejects_bad_example: True · checked: True

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
    (∀ a ∈ i.actions, ∃ c ∈ o.drivingConditions, c = a) ∧
    (∀ s ∈ i.stakeholders, ∃ c ∈ o.drivingConditions, c = s) ∧
    o.drivingConditions.Nodup

example : Spec.pre { actions := ["Action1", "Action2"], stakeholders := ["StakeholderA", "StakeholderB"] } ∧
          Spec.post { actions := ["Action1", "Action2"], stakeholders := ["StakeholderA", "StakeholderB"] }
                    { drivingConditions := ["Action1", "Action2", "StakeholderA", "StakeholderB"] } := by
  unfold Spec; decide
