import ContractForge
open ContractForge

-- 7.2.2.2: 7.2.2.2 It shall be possible for the user of an Operational radio to establish a call with each of the following types of controller (who are not permanently included in a shunting group) with a minimum number of actions being required: primary controller; (M) secondary controller; (M) power supply controller. (O)
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  radioId : Nat
  controllerType : String
  deriving DecidableEq, Repr

structure Output where
  callEstablished : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.controllerType ∈ ["primary", "secondary", "power supply"]
  post := fun i o => (o.callEstablished = true ↔
    (i.controllerType = "primary" ∨
     i.controllerType = "secondary" ∨
     i.controllerType = "power supply"))

example : Spec.pre { radioId := 1, controllerType := "primary" } ∧
          Spec.post { radioId := 1, controllerType := "primary" }
                    { callEstablished := true } := by
  unfold Spec; decide
