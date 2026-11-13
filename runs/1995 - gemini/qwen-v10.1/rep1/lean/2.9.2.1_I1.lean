import ContractForge
open ContractForge

-- 2.9.2.1/I1: Data flow. Data from detectors must be stored in the most effective method permitted by available technology. Astronomical data is often detector readout limited so that disk access and data transfer times are not significant. Maximum acceptable readout time for detector data is very dependent on detector type and size as well as the intended application: For focusing and related activities, maximum acceptable detector readout time is about 0.1 sec, though only a portion of the detector may be read during that time. For mosaicked, large optical detectors, a full readout of the detector must be done in about 2 or 3 minutes.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  detectorType : String
  detectorSize : Nat
  operation    : String
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  operation     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.operation = i.operation ∧
                     (o.operation = "Data flow. Data from detectors must be stored in the most effective method permitted by available technology. Astronomical data is often detector readout limited so that disk access and data transfer times are not significant. Maximum acceptable readout time for detector data is very dependent on detector type and size as well as the intended application: For focusing and related activities, maximum acceptable detector readout time is about 0.1 sec" → o.elapsedMicros ≤ 100000) ∧
                     (o.operation = "Data flow. Data from detectors must be stored in the most effective method permitted by available technology. Astronomical data is often detector readout limited so that disk access and data transfer times are not significant. Maximum acceptable readout time for detector data is very dependent on detector type and size as well as the intended application: For focusing and related activities, maximum acceptable detector readout time is about" → o.elapsedMicros ≤ 180000000)

example : Spec.pre { detectorType := "CCD", detectorSize := 1024, operation := "Data flow. Data from detectors must be stored in the most effective method permitted by available technology. Astronomical data is often detector readout limited so that disk access and data transfer times are not significant. Maximum acceptable readout time for detector data is very dependent on detector type and size as well as the intended application: For focusing and related activities, maximum acceptable detector readout time is about 0.1 sec" } ∧
          Spec.post { detectorType := "CCD", detectorSize := 1024, operation := "Data flow. Data from detectors must be stored in the most effective method permitted by available technology. Astronomical data is often detector readout limited so that disk access and data transfer times are not significant. Maximum acceptable readout time for detector data is very dependent on detector type and size as well as the intended application: For focusing and related activities, maximum acceptable detector readout time is about 0.1 sec", elapsedMicros := 90000 } := by
  unfold Spec; decide
