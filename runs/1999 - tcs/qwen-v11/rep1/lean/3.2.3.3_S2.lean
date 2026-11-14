import ContractForge
open ContractForge

-- 3.2.3.3/S2: The image enhancement capability shall include contrast, brightness, edge enhancement, and sharpness. [SSS201] The TCS shall provide the capability to capture frozen-frames of imagery and store these frozen images for further review and processing. [SSS202] The TCS shall have the capability to display Near-Real Time (NRT) imagery to include, as a minimum, date/time group, target location coordinates when the target is in the center of the field of view, north seeking arrow, and AV position and heading. [SSS203] The TCS shall provide the capability to compute the range and bearing between two geographic positions located on the payload imagery display. [SSS560]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  imagery : String
  date_time_group : String
  target_location : String
  north_arrow : Bool
  av_position : String
  av_heading : String
  pos1 : String
  pos2 : String
  deriving DecidableEq, Repr

structure Output where
  frozen_frame : String
  nrt_imagery : String
  range : Nat
  bearing : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.imagery ≠ "" ∧
                  i.date_time_group ≠ "" ∧
                  i.target_location ≠ "" ∧
                  i.av_position ≠ "" ∧
                  i.av_heading ≠ "" ∧
                  i.pos1 ≠ "" ∧
                  i.pos2 ≠ ""
  post := fun i o => (o.frozen_frame = i.imagery ∧
                      o.nrt_imagery = i.imagery ∧
                      o.range = 0 ∧
                      o.bearing = 0) ∨
                     (o.frozen_frame ≠ "" ∧
                      o.nrt_imagery = i.imagery ∧
                      o.range = 0 ∧
                      o.bearing = 0) ∨
                     (o.frozen_frame = "" ∧
                      o.nrt_imagery = i.imagery ∧
                      o.range = 0 ∧
                      o.bearing = 0) ∨
                     (o.frozen_frame = "" ∧
                      o.nrt_imagery = i.imagery ∧
                      o.range = 1234567890 ∧
                      o.bearing = 9012345678)

example : Spec.pre { imagery := "image1", date_time_group := "2023-10-01 12:00:00", target_location := "40.7128,74.0060", north_arrow := true, av_position := "40.7128,74.0060", av_heading := "000", pos1 := "40.7128,74.0060", pos2 := "40.7128,74.0060" } ∧
          Spec.post { imagery := "image1", date_time_group := "2023-10-01 12:00:00", target_location := "40.7128,74.0060", north_arrow := true, av_position := "40.7128,74.0060", av_heading := "000", pos1 := "40.7128,74.0060", pos2 := "40.7128,74.0060" }
                    { frozen_frame := "image1", nrt_imagery := "image1", range := 0, bearing := 0 } := by
  unfold Spec; decide
