import ContractForge
open ContractForge

-- 3.1.2.1/S6: The link chosen to transfer data should represent as small a bottleneck as possible for data acquisition.
-- compiles: True · rejects_bad_example: True · checked: True

structure Link where
  bandwidth : Nat
  latency   : Nat
  deriving DecidableEq, Repr

structure Input where
  links      : List Link
  requiredBandwidth : Nat
  requiredLatency   : Nat
  deriving DecidableEq, Repr

structure Output where
  chosenLink : Link
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.requiredBandwidth > 0 ∧ i.requiredLatency > 0
  post := fun i o => o.chosenLink.bandwidth ≥ i.requiredBandwidth ∧
                     o.chosenLink.latency ≤ i.requiredLatency ∧
                     (o.chosenLink.bandwidth = i.requiredBandwidth ∧
                      o.chosenLink.latency = i.requiredLatency ↔
                      ∃ l ∈ i.links, l.bandwidth = i.requiredBandwidth ∧ l.latency = i.requiredLatency)

example : Spec.pre { links := [{ bandwidth := 100, latency := 10 },
                                { bandwidth := 200, latency := 5 }],
                     requiredBandwidth := 100,
                     requiredLatency := 10 } ∧
          Spec.post { links := [{ bandwidth := 100, latency := 10 },
                                 { bandwidth := 200, latency := 5 }],
                      requiredBandwidth := 100,
                      requiredLatency := 10 }
                    { chosenLink := { bandwidth := 100, latency := 10 } } := by
  unfold Spec; decide
