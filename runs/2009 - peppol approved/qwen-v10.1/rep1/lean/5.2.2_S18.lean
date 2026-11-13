import ContractForge
open ContractForge

-- 5.2.2/S18: The VCD will be dependent on a number of services that rely on manual and semi-automated input.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  manualInput : Nat
  semiAutomatedInput : Nat
  deriving DecidableEq, Repr

structure Output where
  dependentServices : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.manualInput + i.semiAutomatedInput
  post := fun i o => o.dependentServices = i.manualInput + i.semiAutomatedInput

example : Spec.pre { manualInput := 2, semiAutomatedInput := 3 } ∧
          Spec.post { manualInput := 2, semiAutomatedInput := 3 }
                    { dependentServices := 5 } := by
  unfold Spec; decide
