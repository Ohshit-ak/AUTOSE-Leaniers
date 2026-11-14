import ContractForge
open ContractForge

-- 5.2.2.37: 5.2.2.37 For calls between a controller and the lead cab, it shall be possible to add the controller to the multi-driver call. Either the lead driver calls the controller or the controller calls the lead driver. In the latter case, the controller is automatically added into the multi- driver call. Functional identity of the controller shall be displayed in the leading cab. (M) Call train staff

-- L0 spec

structure Input where
  leadDriverId : String
  controllerId : String
  multiCall : List String
  callingLeadFirst : Bool
  deriving DecidableEq, Repr

structure Output where
  multiCall : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.leadDriverId ≠ "" ∧ i.controllerId ≠ ""
  post := fun i o =>
    (o.multiCall.contains i.leadDriverId ↔ i.multiCall.contains i.leadDriverId) ∧
    (o.multiCall.contains i.controllerId ↔
      (i.multiCall.contains i.leadDriverId ∧ i.multiCall.count i.leadDriverId = 1) ∨
      (i.multiCall.count i.leadDriverId = 0 ∧ i.callingLeadFirst = true))

example : Spec.pre { leadDriverId := "LD1", controllerId := "C1", multiCall := ["LD1"], callingLeadFirst := true } ∧ Spec.post { leadDriverId := "LD1", controllerId := "C1", multiCall := ["LD1"], callingLeadFirst := true } { multiCall := ["LD1", "C1"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { multiCall := x.multiCall }
