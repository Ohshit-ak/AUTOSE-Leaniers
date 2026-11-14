import ContractForge
open ContractForge

-- 3.2.2.3.2/S1: The TCS shall receive, process, and present status data to the operator so that the status of the data terminal and the supported AV data link can be monitored. [SSS177] The TCS shall be capable of monitoring and displaying the signal strength of the received and transmitted signals for the selected data terminal. [SSS178] The TCS shall be capable of monitoring and displaying the signal quality of the received and transmitted signals for the selected data terminal. [SSS179] The TCS shall be capable of presenting to the operator a visual depiction of the minimum and maximum data link operational ranges. [SSS180]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  signalStrengthReceived : Nat
  signalStrengthTransmitted : Nat
  signalQualityReceived : Nat
  signalQualityTransmitted : Nat
  minRange : Nat
  maxRange : Nat
  deriving DecidableEq, Repr

structure Output where
  signalStrengthReceived : Nat
  signalStrengthTransmitted : Nat
  signalQualityReceived : Nat
  signalQualityTransmitted : Nat
  minRange : Nat
  maxRange : Nat
  visualDepiction : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signalStrengthReceived ≤ 100 ∧ i.signalStrengthTransmitted ≤ 100 ∧
                   i.signalQualityReceived ≤ 100 ∧ i.signalQualityTransmitted ≤ 100 ∧
                   i.minRange ≤ i.maxRange
  post := fun i o => o.signalStrengthReceived = i.signalStrengthReceived ∧
                     o.signalStrengthTransmitted = i.signalStrengthTransmitted ∧
                     o.signalQualityReceived = i.signalQualityReceived ∧
                     o.signalQualityTransmitted = i.signalQualityTransmitted ∧
                     o.minRange = i.minRange ∧
                     o.maxRange = i.maxRange ∧
                     o.visualDepiction.length > 0 ∧
                     (o.visualDepiction = "Minimum Range: " ++ i.minRange.toString ++ ", Maximum Range: " ++ i.maxRange.toString)

example : Spec.pre { signalStrengthReceived := 80, signalStrengthTransmitted := 75,
                     signalQualityReceived := 90, signalQualityTransmitted := 85,
                     minRange := 10, maxRange := 20 } ∧
          Spec.post { signalStrengthReceived := 80, signalStrengthTransmitted := 75,
                      signalQualityReceived := 90, signalQualityTransmitted := 85,
                      minRange := 10, maxRange := 20 }
                    { signalStrengthReceived := 80, signalStrengthTransmitted := 75,
                      signalQualityReceived := 90, signalQualityTransmitted := 85,
                      minRange := 10, maxRange := 20,
                      visualDepiction := "Minimum Range: 10, Maximum Range: 20" } := by
  unfold Spec; decide
