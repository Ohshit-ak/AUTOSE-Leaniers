import ContractForge
open ContractForge

-- 7.5.5/S1: SIM cards shall be fixed into the radio such that they can only be removed by the use of a tool.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  toolUsed : Bool
  simFixed : Bool
  deriving DecidableEq, Repr

structure Output where
  simRemoved : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.simFixed = true
  post := fun i o => (o.simRemoved = true ↔ i.toolUsed = true) ∧
                     (o.simRemoved = false ↔ i.toolUsed = false)

example : Spec.pre { toolUsed := false, simFixed := true } ∧
          Spec.post { toolUsed := false, simFixed := true } { simRemoved := false } := by
  unfold Spec; decide
