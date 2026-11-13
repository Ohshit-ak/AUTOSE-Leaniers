import ContractForge
open ContractForge

-- 3.11.5/S1: The total, fully useable, addressable, physically present program instruction memory and data storage memory for each processor shall have at least 50% unused memory during the Normal Operations Mode over any 10 second period. [SSS414] The processing speed of each processor shall be such that at least 50% of the throughput of each processor remains unused over all 10 second periods and at least 20% of the throughput of each processor remains unused over one second periods regardless of the system function performed. [SSS415] The I/O channel reserve capability for each processor shall have at least a 50% reserve, addressable and useable, I/O channel capacity over any 10 second period. [SSS416] TCS software flexibility and expandability shall be provided through use of the DII COE and through use of standardized software development practices. [SSS417]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  elapsedMicros : Nat
  unusedMemory : Nat
  unusedThroughput : Nat
  unusedIOMemory : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  unusedMemory : Nat
  unusedThroughput : Nat
  unusedIOMemory : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o =>
    o.elapsedMicros ≤ 10000000 ∧
    o.unusedMemory ≥ o.elapsedMicros / 2 ∧
    o.unusedThroughput ≥ o.elapsedMicros / 2 ∧
    o.unusedIOMemory ≥ o.elapsedMicros / 2

example : Spec.pre { elapsedMicros := 9500000, unusedMemory := 5000000,
                     unusedThroughput := 4750000, unusedIOMemory := 4750000 } ∧
          Spec.post { elapsedMicros := 9500000, unusedMemory := 5000000,
                      unusedThroughput := 4750000, unusedIOMemory := 4750000 }
                    { elapsedMicros := 9500000, unusedMemory := 5000000,
                      unusedThroughput := 4750000, unusedIOMemory := 4750000 } := by
  unfold Spec; decide
