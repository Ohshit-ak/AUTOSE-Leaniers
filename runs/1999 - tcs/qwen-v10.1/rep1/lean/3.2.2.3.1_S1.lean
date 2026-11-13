import ContractForge
open ContractForge

-- 3.2.2.3.1/S1: The TCS shall be capable of interfacing with the specified data terminal and issuing data link terminal commands required to establish, control, and maintain the data link with a selected AV. [SSS159] Data terminal control shall include, but is not limited to, antenna pointing control, transmitter control, and receiver control. [SSS160] The TCS shall be capable of automatically selecting the proper mode of operation for the selected data terminal. [SSS161] As a minimum the TCS LOS data terminal control modes shall include acquisition, autotrack, search, manual point, omni directional, as well as directional modes of operation, if applicable to the selected data link. [SSS162] The operator shall be able to manually override any automatic data terminal control mode selection if desired, except during Emission Control (EMCON) and Hazards of Electromagnetic Radiation to Ordnance (HERO) conditions. [SSS163] The TCS shall support a LOS data link and SATCOM data link capability. [SSS164] For shipboard operations, the TCS shall provide the capability to switch to a second LOS antenna, if a second antenna is available, when desired (e.g. the currently active antenna is masked by shipboard obstructions). [SSS116] The TCS shall provide the capability to switch to a SATellite COMmunication (SATCOM) antenna, if the selected AV has SATCOM capability, when desire (e.g. the AV proceeds beyond LOS range as well as when LOS is obstructed). [SSS117] The TCS shall provide an interactive display for the purpose of controlling the data link terminal. [SSS165]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mode : String
  antenna : Option Nat
  avHasSatcom : Bool
  deriving DecidableEq, Repr

structure Output where
  mode : String
  antenna : Option Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mode ∈ ["acquisition", "autotrack", "search", "manual point", "omni directional", "directional"] ∨
                   (i.mode = "EMCON" ∧ i.antenna = none) ∨
                   (i.mode = "HERO" ∧ i.antenna = none)
  post := fun i o => (o.mode = i.mode) ∧
                     (o.antenna = i.antenna) ∧
                     (o.mode = "acquisition" → i.mode = "acquisition") ∧
                     (o.mode = "autotrack" → i.mode = "autotrack") ∧
                     (o.mode = "search" → i.mode = "search") ∧
                     (o.mode = "manual point" → i.mode = "manual point") ∧
                     (o.mode = "omni directional" → i.mode = "omni directional") ∧
                     (o.mode = "directional" → i.mode = "directional") ∧
                     (o.mode = "EMCON" → i.mode = "EMCON" ∧ i.antenna = none) ∧
                     (o.mode = "HERO" → i.mode = "HERO" ∧ i.antenna = none) ∧
                     (i.mode = "acquisition" → o.antenna = none) ∧
                     (i.mode = "autotrack" → o.antenna = none) ∧
                     (i.mode = "search" → o.antenna = none) ∧
                     (i.mode = "manual point" → o.antenna = none) ∧
                     (i.mode = "omni directional" → o.antenna = none) ∧
                     (i.mode = "directional" → o.antenna = none) ∧
                     (i.mode = "EMCON" → o.antenna = none) ∧
                     (i.mode = "HERO" → o.antenna = none) ∧
                     (i.avHasSatcom = true → o.antenna = none) ∧
                     (i.avHasSatcom = false → o.antenna = i.antenna)

example : Spec.pre { mode := "acquisition", antenna := none, avHasSatcom := false } ∧
          Spec.post { mode := "acquisition", antenna := none, avHasSatcom := false }
                    { mode := "acquisition", antenna := none } := by
  unfold Spec; decide
