import ContractForge
open ContractForge

-- 5.1/S6: The VCD should encompass this change.
-- compiles: True · rejects_bad_example: True · checked: True

structure Change where
  value : Nat
  deriving DecidableEq, Repr

structure VCD where
  changes : List Change
  deriving DecidableEq, Repr

structure Input where
  change : Change
  deriving DecidableEq, Repr

structure Output where
  vcd : VCD
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.vcd.changes.contains i.change

example : Spec.pre { change := { value := 5 } } ∧
          Spec.post { change := { value := 5 } }
                    { vcd := { changes := [{ value := 5 }] } } := by
  unfold Spec; decide
