import ContractForge
open ContractForge

-- 3.4.3/S1: The TCS shall provide an internal interface for the SAR Processor in order to disseminate SAR information (to include imagery and telemetry) to other components of the TCS. [SSS330] The SAR Processor interface requirements and specifications will be defined in the TCS to SAR Processor IDD, TCS 240.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  sarInfo : String
  deriving DecidableEq, Repr

structure Output where
  disseminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.sarInfo ≠ ""
  post := fun i o => o.disseminated = true ∧
                     (o.disseminated = true ↔
                      -- IMPL: TCS to SAR Processor IDD, TCS 240
                      true)

example : Spec.pre { sarInfo := "SAR data" } ∧
          Spec.post { sarInfo := "SAR data" }
                    { disseminated := true } := by
  unfold Spec; decide
