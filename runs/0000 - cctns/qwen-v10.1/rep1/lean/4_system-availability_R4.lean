import ContractForge
open ContractForge

-- 4/system-availability/R4: The number of incidents of unplanned downtime for the System must not exceed <x> per <rolling three month period>.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  downtimeIncidents : Nat
  deriving DecidableEq, Repr

structure Output where
  downtimeIncidents : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.downtimeIncidents = i.downtimeIncidents ∧
                     (i.downtimeIncidents ≤ 3)

example : Spec.pre { downtimeIncidents := 2 } ∧
          Spec.post { downtimeIncidents := 2 }
                    { downtimeIncidents := 2 } := by
  unfold Spec; decide
