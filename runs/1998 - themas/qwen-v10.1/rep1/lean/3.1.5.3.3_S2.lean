import ContractForge
open ContractForge

-- 3.1.5.3.3/S2: This request shall include the designation of the heating or cooling unit and a flag to indicate whether that unit is to be turned on or off.
-- compiles: True · rejects_bad_example: True · checked: True

structure HeatingCoolingUnit where
  designation : String
  on          : Bool
  deriving DecidableEq, Repr

structure Input where
  designation : String
  on          : Bool
  deriving DecidableEq, Repr

structure Output where
  designation : String
  on          : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.designation = i.designation ∧ o.on = i.on

example : Spec.pre { designation := "HVAC123", on := true } ∧
          Spec.post { designation := "HVAC123", on := true }
                    { designation := "HVAC123", on := true } := by
  unfold Spec; decide
