import ContractForge
open ContractForge

-- 4.3.10.2: All data entered, received or indicated to the driver shall be recorded onboard. All data shall be related to UTC (Universal Time Corrected) and a reference point.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : List String
  referencePoint : Nat
  deriving DecidableEq, Repr

structure Output where
  recordedData : List String
  referencePoint : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.data ≠ []
  post := fun i o => o.recordedData = i.data ∧ o.referencePoint = i.referencePoint

example : Spec.pre { data := ["data1", "data2"], referencePoint := 12345 } ∧
          Spec.post { data := ["data1", "data2"], referencePoint := 12345 }
                    { recordedData := ["data1", "data2"], referencePoint := 12345 } := by
  unfold Spec; decide
