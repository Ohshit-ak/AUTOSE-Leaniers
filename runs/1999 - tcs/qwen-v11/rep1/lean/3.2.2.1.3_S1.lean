import ContractForge
open ContractForge

-- 3.2.2.1.3/S1: The TCS shall provide the functionality to control, monitor, and display the operation of the Air Data Terminal (ADT). [SSS132] This control will include control of the ADT antenna and of the ADT transmitter and receiver.
-- compiles: True · rejects_bad_example: True · checked: True

structure ADTControl where
  antennaControl : Bool
  transmitterControl : Bool
  receiverControl : Bool
  deriving DecidableEq, Repr

structure Input where
  adtControl : ADTControl
  deriving DecidableEq, Repr

structure Output where
  adtControl : ADTControl
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.adtControl.antennaControl ∨ i.adtControl.transmitterControl ∨ i.adtControl.receiverControl
  post := fun i o => (o.adtControl.antennaControl = i.adtControl.antennaControl ∨
                      (o.adtControl.antennaControl = true ∧ i.adtControl.antennaControl = false)) ∧
                     (o.adtControl.transmitterControl = i.adtControl.transmitterControl ∨
                      (o.adtControl.transmitterControl = true ∧ i.adtControl.transmitterControl = false)) ∧
                     (o.adtControl.receiverControl = i.adtControl.receiverControl ∨
                      (o.adtControl.receiverControl = true ∧ i.adtControl.receiverControl = false))

example : Spec.pre { adtControl := { antennaControl := true, transmitterControl := false, receiverControl := false } } ∧
          Spec.post { adtControl := { antennaControl := true, transmitterControl := false, receiverControl := false } }
                    { adtControl := { antennaControl := true, transmitterControl := false, receiverControl := false } } := by
  unfold Spec; decide
