import ContractForge
open ContractForge

-- 3.3.1/S2: Given the large number of instruments, there can be many different stations which are active at the same time.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  activeStations : List String
  deriving DecidableEq, Repr

structure Output where
  activeStations : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.activeStations.Nodup
  post := fun i o => o.activeStations = i.activeStations

example : Spec.pre { activeStations := ["Station1", "Station2"] } ∧
          Spec.post { activeStations := ["Station1", "Station2"] }
                    { activeStations := ["Station1", "Station2"] } := by
  unfold Spec; decide
