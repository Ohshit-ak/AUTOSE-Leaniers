import ContractForge
open ContractForge

-- 3.1.1.3.1/S1: There shall be a maximum number of heating or cooling u nits that can be on at any given time.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  maxUnits : Nat
  currentUnits : Nat
  deriving DecidableEq, Repr

structure Output where
  currentUnits : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.maxUnits ∧ i.currentUnits ≤ i.maxUnits
  post := fun i o => o.currentUnits = i.currentUnits ∧
                     o.currentUnits ≤ i.maxUnits

example : Spec.pre { maxUnits := 5, currentUnits := 3 } ∧
          Spec.post { maxUnits := 5, currentUnits := 3 }
                    { currentUnits := 3 } := by
  unfold Spec; decide
