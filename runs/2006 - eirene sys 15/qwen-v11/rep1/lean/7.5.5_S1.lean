import ContractForge
open ContractForge

-- 7.5.5/S1: SIM cards shall be fixed into the radio such that they can only be removed by the use of a tool.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  toolUsed : Bool
  deriving DecidableEq, Repr

structure Output where
  simRemoved : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.toolUsed = false
  post := fun i o => o.simRemoved = false ∧
                     (o.simRemoved = true ↔ i.toolUsed = true)

example : Spec.pre { toolUsed := false } ∧ Spec.post { toolUsed := false } { simRemoved := false } := by
  unfold Spec; decide
