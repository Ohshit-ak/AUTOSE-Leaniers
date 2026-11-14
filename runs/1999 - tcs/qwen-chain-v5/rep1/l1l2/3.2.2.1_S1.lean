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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  passControlTo : Option String
  receiveControlFrom : Option String
  controlPassed : Bool
  controlReceived : Bool
  avType : String
  isInteroperable : Bool
  notifyLimit : Bool
  deriving DecidableEq, Repr

def ComputeControlContract : Contract Input Mid where
  pre  := fun i => i.isInteroperable = true
  post := fun i m => ((m.passControlTo = i.passControlTo) ∧
    (m.receiveControlFrom = i.receiveControlFrom) ∧
    (m.controlPassed = (m.passControlTo.isSome ∧ m.passControlTo.getD "" ≠ i.receiveControlFrom.getD "")) ∧
    (m.controlReceived = false)) ∧ m.avType = i.avType ∧ m.isInteroperable = i.isInteroperable ∧ m.notifyLimit = i.notifyLimit

def ApplyControlContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.avType = m.avType) ∧
    (o.isInteroperable = m.isInteroperable) ∧
    (o.notifyLimit = m.notifyLimit) ∧
    (o.passControlTo.getD "" = m.passControlTo.getD "") ∧
    (o.receiveControlFrom.getD "" = m.receiveControlFrom.getD "") ∧
    (o.controlPassed = m.controlPassed) ∧
    (o.controlReceived = (m.receiveControlFrom.isSome ∧ m.receiveControlFrom.getD "" ≠ m.passControlTo.getD ""))


