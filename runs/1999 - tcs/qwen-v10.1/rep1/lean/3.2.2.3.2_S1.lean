import ContractForge
open ContractForge

-- 3.2.2.3.2/S1: The TCS shall receive, process, and present status data to the operator so that the status of the data terminal and the supported AV data link can be monitored. [SSS177] The TCS shall be capable of monitoring and displaying the signal strength of the received and transmitted signals for the selected data terminal. [SSS178] The TCS shall be capable of monitoring and displaying the signal quality of the received and transmitted signals for the selected data terminal. [SSS179] The TCS shall be capable of presenting to the operator a visual depiction of the minimum and maximum data link operational ranges. [SSS180]
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  signalStrengthReceived : Nat
  signalStrengthTransmitted : Nat
  signalQualityReceived : Nat
  signalQualityTransmitted : Nat
  minDataLinkRange : Nat
  maxDataLinkRange : Nat
  deriving DecidableEq, Repr

structure Output where
  signalStrengthReceived : Nat
  signalStrengthTransmitted : Nat
  signalQualityReceived : Nat
  signalQualityTransmitted : Nat
  minDataLinkRange : Nat
  maxDataLinkRange : Nat
  visualDepiction : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signalStrengthReceived ≤ 100 ∧ i.signalStrengthTransmitted ≤ 100 ∧
                   i.signalQualityReceived ≤ 100 ∧ i.signalQualityTransmitted ≤ 100
  post := fun i o => (o.signalStrengthReceived = i.signalStrengthReceived) ∧
                     (o.signalStrengthTransmitted = i.signalStrengthTransmitted) ∧
                     (o.signalQualityReceived = i.signalQualityReceived) ∧
                     (o.signalQualityTransmitted = i.signalQualityTransmitted) ∧
                     (o.minDataLinkRange = i.minDataLinkRange) ∧
                     (o.maxDataLinkRange = i.maxDataLinkRange) ∧
                     (o.visualDepiction.length > 0) ∧
                     (o.visualDepiction.contains "min" ∧ o.visualDepiction.contains "max")

example : Spec.pre { signalStrengthReceived := 80, signalStrengthTransmitted := 70,
                     signalQualityReceived := 90, signalQualityTransmitted := 85,
                     minDataLinkRange := 100, maxDataLinkRange := 200 } ∧
          Spec.post { signalStrengthReceived := 80, signalStrengthTransmitted := 70,
                      signalQualityReceived := 90, signalQualityTransmitted := 85,
                      minDataLinkRange := 100, maxDataLinkRange := 200,
                      visualDepiction := "Min: 100, Max: 200" } := by
  unfold Spec; decide
