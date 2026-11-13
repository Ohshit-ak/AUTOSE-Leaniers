import ContractForge
open ContractForge

-- 4.3.1/S11: Changes in the rule set will directly result in changes in the orchestration logic without any coding tasks and are executed immediately.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { updatedLogic := x.currentRules ++ x.newRules }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
