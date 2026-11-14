import ContractForge
open ContractForge

-- 3.2.2.3.1/S1: The TCS shall be capable of interfacing with the specified data terminal and issuing data link terminal commands required to establish, control, and maintain the data link with a selected AV. [SSS159] Data terminal control shall include, but is not limited to, antenna pointing control, transmitter control, and receiver control. [SSS160] The TCS shall be capable of automatically selecting the proper mode of operation for the selected data terminal. [SSS161] As a minimum the TCS LOS data terminal control modes shall include acquisition, autotrack, search, manual point, omni directional, as well as directional modes of operation, if applicable to the selected data link. [SSS162] The operator shall be able to manually override any automatic data terminal control mode selection if desired, except during Emission Control (EMCON) and Hazards of Electromagnetic Radiation to Ordnance (HERO) conditions. [SSS163] The TCS shall support a LOS data link and SATCOM data link capability. [SSS164] For shipboard operations, the TCS shall provide the capability to switch to a second LOS antenna, if a second antenna is available, when desired (e.g. the currently active antenna is masked by shipboard obstructions). [SSS116] The TCS shall provide the capability to switch to a SATellite COMmunication (SATCOM) antenna, if the selected AV has SATCOM capability, when desire (e.g. the AV proceeds beyond LOS range as well as when LOS is obstructed). [SSS117] The TCS shall provide an interactive display for the purpose of controlling the data link terminal. [SSS165]
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  mode : String
  antennaPointing : Bool
  transmitterControl : Bool
  receiverControl : Bool
  secondAntennaAvailable : Bool
  satcomCapability : Bool
  deriving DecidableEq, Repr

structure Output where
  selectedMode : String
  antennaPointing : Bool
  transmitterControl : Bool
  receiverControl : Bool
  secondAntenna : Bool
  satcom : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mode ∈ ["acquisition", "autotrack", "search", "manual point", "omni directional", "directional"] ∧
                   (i.mode ≠ "acquisition" ∨ i.antennaPointing) ∧
                   (i.mode ≠ "manual point" ∨ i.transmitterControl) ∧
                   (i.mode ≠ "manual point" ∨ i.receiverControl) ∧
                   i.mode ≠ "acquisition" ∨ i.secondAntennaAvailable ∧
                   i.mode ≠ "acquisition" ∨ i.satcomCapability
  post := fun i o => 
    o.selectedMode = i.mode ∧
    o.antennaPointing = i.antennaPointing ∧
    o.transmitterControl = i.transmitterControl ∧
    o.receiverControl = i.receiverControl ∧
    o.secondAntenna = i.secondAntennaAvailable ∧
    o.satcom = i.satcomCapability

example : Spec.pre { mode := "autotrack", antennaPointing := true, transmitterControl := false, receiverControl := false, secondAntennaAvailable := false, satcomCapability := true } ∧
          Spec.post { mode := "autotrack", antennaPointing := true, transmitterControl := false, receiverControl := false, secondAntennaAvailable := false, satcomCapability := true }
                    { selectedMode := "autotrack", antennaPointing := true, transmitterControl := false, receiverControl := false, secondAntenna := false, satcom := true } := by
  unfold Spec; decide
