import ContractForge
open ContractForge

-- 3.3.2/S7: Microprocessor software in particular tends to contain hardware specific software, though one should try to keep it as hardware independent as possible, isolating different software layers.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  hardwareLayer : String
  deriving DecidableEq, Repr

structure Output where
  hardwareIndependent : Bool
  softwareLayer : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True  -- No specific assumptions about the input
  post := fun i o => (o.hardwareIndependent = true ↔
    i.hardwareLayer ≠ "specific" ∧ o.softwareLayer = "independent")

example : Spec.pre { hardwareLayer := "general" } ∧
          Spec.post { hardwareLayer := "general" }
                    { hardwareIndependent := true, softwareLayer := "independent" } := by
  unfold Spec; decide
