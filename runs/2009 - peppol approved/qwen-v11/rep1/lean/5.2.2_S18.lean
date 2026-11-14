import ContractForge
open ContractForge

-- 5.2.2/S18: The VCD will be dependent on a number of services that rely on manual and semi-automated input.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  manualInput : Bool
  semiAutomatedInput : Bool
  deriving DecidableEq, Repr

structure Output where
  dependentOnServices : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.manualInput ∨ i.semiAutomatedInput
  post := fun i o => o.dependentOnServices = true ∧
                     (o.dependentOnServices = i.manualInput ∨ o.dependentOnServices = i.semiAutomatedInput)

example : Spec.pre { manualInput := true, semiAutomatedInput := false } ∧
          Spec.post { manualInput := true, semiAutomatedInput := false }
                    { dependentOnServices := true } := by
  unfold Spec; decide
