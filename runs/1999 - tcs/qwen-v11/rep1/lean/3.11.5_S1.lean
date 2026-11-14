import ContractForge
open ContractForge

-- 3.11.5/S1: The total, fully useable, addressable, physically present program instruction memory and data storage memory for each processor shall have at least 50% unused memory during the Normal Operations Mode over any 10 second period. [SSS414] The processing speed of each processor shall be such that at least 50% of the throughput of each processor remains unused over all 10 second periods and at least 20% of the throughput of each processor remains unused over one second periods regardless of the system function performed. [SSS415] The I/O channel reserve capability for each processor shall have at least a 50% reserve, addressable and useable, I/O channel capacity over any 10 second period. [SSS416] TCS software flexibility and expandability shall be provided through use of the DII COE and through use of standardized software development practices. [SSS417]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  unusedMemory  : Nat
  unusedThroughput : Nat
  unusedIOMemory : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 10000000 ∧
                     o.unusedMemory ≥ o.elapsedMicros * 50 / 100 ∧
                     o.unusedThroughput ≥ o.elapsedMicros * 50 / 100 ∧
                     o.unusedIOMemory ≥ o.elapsedMicros * 50 / 100

example : Spec.pre { elapsedMicros := 8000000, unusedMemory := 4000000, unusedThroughput := 4000000, unusedIOMemory := 4000000 } ∧
          Spec.post { elapsedMicros := 8000000, unusedMemory := 4000000, unusedThroughput := 4000000, unusedIOMemory := 4000000 } := by
  unfold Spec; decide
