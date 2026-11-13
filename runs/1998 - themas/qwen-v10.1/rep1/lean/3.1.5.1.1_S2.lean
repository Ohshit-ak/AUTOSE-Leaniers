import ContractForge
open ContractForge

-- 3.1.5.1.1/S2: The THEMAS system shall limit the number of heating or cooling units t hat may be running simultaneously.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  runningUnits : Nat
  maxUnits     : Nat
  deriving DecidableEq, Repr

structure Output where
  runningUnits : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.runningUnits ≤ i.maxUnits
  post := fun i o => o.runningUnits = i.runningUnits

example : Spec.pre { runningUnits := 5, maxUnits := 10 } ∧
          Spec.post { runningUnits := 5, maxUnits := 10 } { runningUnits := 5 } := by
  unfold Spec; decide
