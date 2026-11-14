import ContractForge
open ContractForge

-- 3.2.2.1/S1: The TCS shall be capable of being interoperable with Predator and Outrider UAVs across the 5 levels of UAV interaction. [SSS011] The TCS shall have the capability to control and monitor multiple types of AVs. [SSS112] TCS shall notify the operator when AV performance parameters are out of limits. [SSS113] The TCS shall provide the capability to pass control of an AV to another TCS [SSS114], and receive control of an AV from another TCS [SSS115].

-- L0 spec

structure Input where
  avType : String
  isInteroperable : Bool
  notifyLimit : Bool
  passControlTo : Option String
  receiveControlFrom : Option String
  deriving DecidableEq, Repr

structure Output where
  avType : String
  isInteroperable : Bool
  notifyLimit : Bool
  passControlTo : Option String
  receiveControlFrom : Option String
  controlPassed : Bool
  controlReceived : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isInteroperable = true
  post := fun i o =>
    (o.avType = i.avType) ∧
    (o.isInteroperable = i.isInteroperable) ∧
    (o.notifyLimit = i.notifyLimit) ∧
    (o.passControlTo.getD "" = i.passControlTo.getD "") ∧
    (o.receiveControlFrom.getD "" = i.receiveControlFrom.getD "") ∧
    (o.controlPassed = (o.passControlTo.isSome ∧ o.passControlTo.getD "" ≠ i.receiveControlFrom.getD "")) ∧
    (o.controlReceived = (o.receiveControlFrom.isSome ∧ o.receiveControlFrom.getD "" ≠ i.passControlTo.getD ""))

example : Spec.pre { avType := "Predator", isInteroperable := true, notifyLimit := true,
                     passControlTo := some "Outrider", receiveControlFrom := none } ∧
          Spec.post { avType := "Predator", isInteroperable := true, notifyLimit := true,
                      passControlTo := some "Outrider", receiveControlFrom := none }
                    { avType := "Predator", isInteroperable := true, notifyLimit := true,
                      passControlTo := some "Outrider", receiveControlFrom := none, controlPassed := true, controlReceived := false } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  passControlTo : Option String
  controlPassed : Bool
  controlReceived : Bool
  avType : String
  isInteroperable : Bool
  notifyLimit : Bool
  receiveControlFrom : Option String
  deriving DecidableEq, Repr

def ComputeControlPassContract : Contract Input Mid where
  pre  := fun i => i.isInteroperable = true
  post := fun i m => ((m.passControlTo = i.passControlTo) ∧
    (m.controlPassed = (m.passControlTo.isSome ∧ m.passControlTo.getD "" ≠ i.receiveControlFrom.getD ""))) ∧ m.avType = i.avType ∧ m.isInteroperable = i.isInteroperable ∧ m.notifyLimit = i.notifyLimit ∧ m.receiveControlFrom = i.receiveControlFrom

def DetermineControlStatusContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.avType = m.avType) ∧
    (o.isInteroperable = m.isInteroperable) ∧
    (o.notifyLimit = m.notifyLimit) ∧
    (o.passControlTo = m.passControlTo) ∧
    (o.receiveControlFrom = m.receiveControlFrom) ∧
    (o.controlPassed = m.controlPassed) ∧
    (o.controlReceived = (m.receiveControlFrom.isSome ∧ m.receiveControlFrom.getD "" ≠ m.passControlTo.getD ""))



theorem po1 : Contract.Compatible ComputeControlPassContract DetermineControlStatusContract := by
  discharge_po1 [ComputeControlPassContract, DetermineControlStatusContract, Spec]

theorem po2 : Contract.Refines (ComputeControlPassContract.seq DetermineControlStatusContract) Spec := by
  discharge_po2 [ComputeControlPassContract, DetermineControlStatusContract, Spec]

-- L2 ComputeControlPassContract (success=True)

def ComputeControlPassContractImpl (x : Input) : Mid :=
  { passControlTo := x.passControlTo,
    controlPassed := (x.passControlTo.isSome ∧ x.passControlTo.getD "" ≠ x.receiveControlFrom.getD ""),
    controlReceived := false,
    avType := x.avType,
    isInteroperable := x.isInteroperable,
    notifyLimit := x.notifyLimit,
    receiveControlFrom := x.receiveControlFrom }

theorem ComputeControlPassContractImpl_ok : ComputeControlPassContract.Satisfies ComputeControlPassContractImpl := by
  discharge_po3 [ComputeControlPassContract, ComputeControlPassContractImpl]

-- L2 DetermineControlStatusContract (success=True)

def DetermineControlStatusContractImpl (x : Mid) : Output :=
  { avType := x.avType,
    isInteroperable := x.isInteroperable,
    notifyLimit := x.notifyLimit,
    passControlTo := x.passControlTo,
    receiveControlFrom := x.receiveControlFrom,
    controlPassed := x.controlPassed,
    controlReceived := x.receiveControlFrom.isSome ∧ x.receiveControlFrom.getD "" ≠ x.passControlTo.getD "" }

theorem DetermineControlStatusContractImpl_ok : DetermineControlStatusContract.Satisfies DetermineControlStatusContractImpl := by
  discharge_po3 [DetermineControlStatusContract, DetermineControlStatusContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (DetermineControlStatusContractImpl ∘ ComputeControlPassContractImpl) :=
  Contract.system_sound po1 po2 ComputeControlPassContractImpl_ok DetermineControlStatusContractImpl_ok
