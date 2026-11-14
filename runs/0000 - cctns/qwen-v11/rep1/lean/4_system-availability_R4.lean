import ContractForge
open ContractForge

-- 4/system-availability/R4: The number of incidents of unplanned downtime for the System must not exceed <x> per <rolling three month period>.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  downtimeCount : Nat
  rollingPeriod : Nat
  deriving DecidableEq, Repr

structure Output where
  downtimeCount : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.downtimeCount ≤ 3
  post := fun i o => o.downtimeCount = i.downtimeCount ∧
                     (o.downtimeCount < i.downtimeCount ↔ i.downtimeCount > 3)

example : Spec.pre { downtimeCount := 2, rollingPeriod := 90 } ∧
          Spec.post { downtimeCount := 2, rollingPeriod := 90 }
                    { downtimeCount := 2 } := by
  unfold Spec; decide
