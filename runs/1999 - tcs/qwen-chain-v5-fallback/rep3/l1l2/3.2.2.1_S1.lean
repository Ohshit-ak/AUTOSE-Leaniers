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

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { avType := x.avType,
    isInteroperable := x.isInteroperable,
    notifyLimit := x.notifyLimit,
    passControlTo := x.passControlTo,
    receiveControlFrom := x.receiveControlFrom,
    controlPassed := (x.passControlTo.isSome ∧ x.passControlTo.getD "" ≠ x.receiveControlFrom.getD "" : Bool),
    controlReceived := (x.receiveControlFrom.isSome ∧ x.receiveControlFrom.getD "" ≠ x.passControlTo.getD "" : Bool) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
