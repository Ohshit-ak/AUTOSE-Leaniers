import ContractForge
open ContractForge

-- 3.4.3/S1: The TCS shall provide an internal interface for the SAR Processor in order to disseminate SAR information (to include imagery and telemetry) to other components of the TCS. [SSS330] The SAR Processor interface requirements and specifications will be defined in the TCS to SAR Processor IDD, TCS 240.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  imagery  : String
  telemetry : String
  deriving DecidableEq, Repr

structure Output where
  disseminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.imagery ≠ "" ∧ i.telemetry ≠ ""
  post := fun i o => o.disseminated = true ∧
                     (i.imagery = "" → o.disseminated = false) ∧
                     (i.telemetry = "" → o.disseminated = false) ∧
                     (o.disseminated = true ↔ i.imagery ≠ "" ∧ i.telemetry ≠ "")

example : Spec.pre { imagery := "image1", telemetry := "telemetry1" } ∧
          Spec.post { imagery := "image1", telemetry := "telemetry1" }
                    { disseminated := true } := by
  unfold Spec; decide
