import ContractForge
open ContractForge

-- 4.3.1/S11: Changes in the rule set will directly result in changes in the orchestration logic without any coding tasks and are executed immediately.
-- compiles: True · rejects_bad_example: True · checked: True

structure RuleSetChange where
  newRules : List String
  deriving DecidableEq, Repr

structure OrchestrationLogic where
  logic : List String
  deriving DecidableEq, Repr

structure Input where
  currentRules : List String
  newRules     : List String
  deriving DecidableEq, Repr

structure Output where
  updatedLogic : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentRules.Nodup
  post := fun i o => o.updatedLogic = i.currentRules ++ i.newRules

example : Spec.pre { currentRules := ["rule1", "rule2"], newRules := ["rule3"] } ∧
          Spec.post { currentRules := ["rule1", "rule2"], newRules := ["rule3"] }
                    { updatedLogic := ["rule1", "rule2", "rule3"] } := by
  unfold Spec; decide
