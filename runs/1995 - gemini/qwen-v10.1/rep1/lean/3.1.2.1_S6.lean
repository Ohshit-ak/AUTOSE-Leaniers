import ContractForge
open ContractForge

-- 3.1.2.1/S6: The link chosen to transfer data should represent as small a bottleneck as possible for data acquisition.
-- compiles: False · rejects_bad_example: None · checked: False

structure Link where
  bandwidth : Nat
  latency   : Nat
  deriving DecidableEq, Repr

structure Input where
  links : List Link
  deriving DecidableEq, Repr

structure Output where
  chosenLink : Link
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.links.Nodup
  post := fun i o => o.chosenLink.bandwidth = i.links.min (·.bandwidth) ∧
                     o.chosenLink.latency = i.links.min (·.latency)

example : Spec.pre { links := [{ bandwidth := 1000, latency := 50 },
                                { bandwidth := 1500, latency := 30 },
                                { bandwidth := 2000, latency := 20 }] } ∧
          Spec.post { links := [{ bandwidth := 1000, latency := 50 },
                                 { bandwidth := 1500, latency := 30 },
                                 { bandwidth := 2000, latency := 20 }] }
                    { chosenLink := { bandwidth := 1500, latency := 30 } } := by
  unfold Spec; decide
