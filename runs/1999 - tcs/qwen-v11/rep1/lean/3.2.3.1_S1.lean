import ContractForge
open ContractForge

-- 3.2.3.1/S1: The TCS shall have the functionality to process payload product data from Electro Optical (EO), Infrared (IR), and Synthetic Aperture Radar (SAR) payloads. [SSS182] This functionality, as a minimum, shall include: formatting, storing, internally routing, and recording the video [SSS190]; creating and storing a freeze frame of the video [SSS191]; retrieving and displaying the video [SSS192]; printing a hard copy of freeze frame video [SSS193]; and processing digital imagery for export and dissemination [SSS194].
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  video : String
  freezeFrame : String
  isSAR : Bool
  deriving DecidableEq, Repr

structure Output where
  formatted : String
  stored : String
  routed : String
  recorded : String
  freezeFrameStored : String
  videoRetrieved : String
  videoDisplayed : String
  freezeFramePrinted : String
  imageryProcessed : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.video ≠ "" ∧ i.freezeFrame ≠ "" ∧ i.isSAR
  post := fun i o => 
    if i.isSAR then
      o.formatted = i.video ∧
      o.stored = i.video ∧
      o.routed = i.video ∧
      o.recorded = i.video ∧
      o.freezeFrameStored = i.freezeFrame ∧
      o.videoRetrieved = i.video ∧
      o.videoDisplayed = i.video ∧
      o.freezeFramePrinted = i.freezeFrame ∧
      o.imageryProcessed = i.video
    else
      o.formatted = i.video ∧
      o.stored = i.video ∧
      o.routed = i.video ∧
      o.recorded = i.video ∧
      o.freezeFrameStored = i.freezeFrame ∧
      o.videoRetrieved = i.video ∧
      o.videoDisplayed = i.video ∧
      o.freezeFramePrinted = i.freezeFrame ∧
      o.imageryProcessed = i.video

example : Spec.pre { video := "SAR_data", freezeFrame := "freeze_frame_SAR", isSAR := true } ∧ Spec.post { video := "SAR_data", freezeFrame := "freeze_frame_SAR", isSAR := true } { formatted := "SAR_data", stored := "SAR_data", routed := "SAR_data", recorded := "SAR_data", freezeFrameStored := "freeze_frame_SAR", videoRetrieved := "SAR_data", videoDisplayed := "SAR_data", freezeFramePrinted := "freeze_frame_SAR", imageryProcessed := "SAR_data" } := by
  unfold Spec; decide
