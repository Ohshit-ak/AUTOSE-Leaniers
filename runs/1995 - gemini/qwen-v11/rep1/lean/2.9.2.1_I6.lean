import ContractForge
open ContractForge

-- 2.9.2.1/I6: System-wide data capacity. The data capacity of the system is limited by transfer methods and technology, as well as archiving capacity on site. The system data capacity is capable of retaining 7 days of data produced by the largest instrument, the last 3 days of which must be available interactively from hard disk or similar medium.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  largestInstrumentData : Nat
  deriving DecidableEq, Repr

structure Output where
  retainedData : Nat
  interactiveData : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.retainedData = 7 * i.largestInstrumentData ∧
                     o.interactiveData = 3 * i.largestInstrumentData

example : Spec.pre { largestInstrumentData := 100 } ∧
          Spec.post { largestInstrumentData := 100 }
                    { retainedData := 700, interactiveData := 300 } := by
  unfold Spec; decide
