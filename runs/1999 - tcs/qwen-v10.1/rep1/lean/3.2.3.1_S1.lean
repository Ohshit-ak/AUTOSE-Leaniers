import ContractForge
open ContractForge

-- 3.2.3.1/S1: The TCS shall have the functionality to process payload product data from Electro Optical (EO), Infrared (IR), and Synthetic Aperture Radar (SAR) payloads. [SSS182] This functionality, as a minimum, shall include: formatting, storing, internally routing, and recording the video [SSS190]; creating and storing a freeze frame of the video [SSS191]; retrieving and displaying the video [SSS192]; printing a hard copy of freeze frame video [SSS193]; and processing digital imagery for export and dissemination [SSS194].
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  video : String
  freezeFrame : String
  deriving DecidableEq, Repr

structure Output where
  formatted : String
  stored : String
  routed : String
  recorded : String
  freezeFrameStored : String
  videoRetrieved : String
  freezeFramePrinted : String
  imageryProcessed : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.video ≠ "" ∧ i.freezeFrame ≠ ""
  post := fun i o => 
    (o.formatted = i.video ∧ o.stored = i.video ∧ o.routed = i.video ∧ o.recorded = i.video) ∧
    (o.freezeFrameStored = i.freezeFrame) ∧
    (o.videoRetrieved = i.video) ∧
    (o.freezeFramePrinted = i.freezeFrame) ∧
    (o.imageryProcessed = i.video)

example : Spec.pre { video := "EO_data", freezeFrame := "freeze_frame" } ∧
          Spec.post { video := "EO_data", freezeFrame := "freeze_frame" }
                    { formatted := "EO_data", stored := "EO_data", routed := "EO_data", recorded := "EO_data",
                      freezeFrameStored := "freeze_frame", videoRetrieved := "EO_data", freezeFramePrinted := "freeze_frame",
                      imageryProcessed := "EO_data" } := by
  unfold Spec; decide
