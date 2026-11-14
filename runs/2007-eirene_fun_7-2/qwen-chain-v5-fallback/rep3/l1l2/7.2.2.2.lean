import ContractForge
open ContractForge

-- 7.2.2.2: 7.2.2.2 It shall be possible for the user of an Operational radio to establish a call with each of the following types of controller (who are not permanently included in a shunting group) with a minimum number of actions being required: primary controller; (M) secondary controller; (M) power supply controller. (O)

-- L0 spec

structure Input where
  radio : String
  primaryController : String
  secondaryController : Option String
  powerSupplyController : Option String
  deriving DecidableEq, Repr

structure Output where
  callEstablished : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.radio ≠ ""
  post := fun i o => (o.callEstablished = true ↔
    (i.primaryController ≠ "" ∨
     i.secondaryController.isSome ∧ i.secondaryController.getD "" ≠ "" ∨
     i.powerSupplyController.isNone)) ∧
    (o.callEstablished = false ↔
      (i.primaryController = "" ∧ i.secondaryController.isNone ∧ i.powerSupplyController.isSome))

example : Spec.pre { radio := "R1", primaryController := "C1", secondaryController := none, powerSupplyController := some "PS1" } ∧ Spec.post { radio := "R1", primaryController := "C1", secondaryController := none, powerSupplyController := some "PS1" } { callEstablished := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { callEstablished := decide (x.primaryController = "" ∧ x.secondaryController.isNone ∧ x.powerSupplyController.isSome) }
