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

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { navigationMethod := x.navigationMethod,
    operatorCommand := x.operatorCommand,
    commandSent := true,
    manualOverride := (x.operatorCommand = "override") }
