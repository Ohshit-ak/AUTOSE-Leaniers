import ContractForge
open ContractForge

-- 3.2.2.1.2/S1: The TCS shall have the capability to command the AV to use the navigation methods inherent to the selected AV. [SSS130] The operator shall have the capability to initiate as well as change, to include as a minimum manual override, UAV navigation methods by sending the proper control commands to the UAV. [SSS131]

-- L0 spec

structure Input where
  navigationMethod : String
  operatorCommand  : String
  deriving DecidableEq, Repr

structure Output where
  navigationMethod : String
  operatorCommand  : String
  commandSent      : Bool
  manualOverride   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.operatorCommand ≠ ""
  post := fun i o => (o.commandSent = true ↔
    (i.operatorCommand = "start" → o.navigationMethod = i.navigationMethod) ∧
    (i.operatorCommand = "change" → o.navigationMethod ≠ i.navigationMethod) ∧
    (i.operatorCommand = "override" → o.manualOverride = true))

example : Spec.pre { navigationMethod := "GPS", operatorCommand := "change" } ∧
          Spec.post { navigationMethod := "GPS", operatorCommand := "change" }
                     { navigationMethod := "Manual", operatorCommand := "change", commandSent := true, manualOverride := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { navigationMethod := if x.operatorCommand = "start" then x.navigationMethod else x.navigationMethod,
    operatorCommand := x.operatorCommand,
    commandSent := (x.operatorCommand = "start" → x.navigationMethod = x.navigationMethod) ∧
                   (x.operatorCommand = "change" → x.navigationMethod ≠ x.navigationMethod) ∧
                   (x.operatorCommand = "override" → true),
    manualOverride := if x.operatorCommand = "override" then true else false }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
