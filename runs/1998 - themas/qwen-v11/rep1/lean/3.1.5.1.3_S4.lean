import ContractForge
open ContractForge

-- 3.1.5.1.3/S4: If the maximum number of heating or cooling units is already running, the request will be added to a LIFO queue.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  maxUnits : Nat
  runningUnits : Nat
  request : Bool
  deriving DecidableEq, Repr

structure Output where
  maxUnits : Nat
  runningUnits : Nat
  inQueue : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.runningUnits ≤ i.maxUnits
  post := fun i o => (o.runningUnits = i.runningUnits + 1 ∧ o.inQueue = false) ↔
                     (i.request = true ∧ i.runningUnits = i.maxUnits) ∧
                     (o.runningUnits = i.runningUnits ∧ o.inQueue = true →
                      i.request = true ∧ i.runningUnits < i.maxUnits)

example : Spec.pre { maxUnits := 5, runningUnits := 4, request := true } ∧
          Spec.post { maxUnits := 5, runningUnits := 4, request := true }
                    { maxUnits := 5, runningUnits := 4, inQueue := true } := by
  unfold Spec; decide
