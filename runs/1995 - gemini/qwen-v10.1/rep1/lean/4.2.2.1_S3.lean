import ContractForge
open ContractForge

-- 4.2.2.1/S3: This means the video data signals must be encoded digitally and transferred via the WAN to remote sites.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  videoData : List String
  deriving DecidableEq, Repr

structure Output where
  encodedData : List String
  transferred : Bool
  deriving DecidableEq, Repr

-- IMPL: Digital encoding and WAN transfer

def Spec : Contract Input Output where
  pre  := fun i => i.videoData.length > 0
  post := fun i o => o.transferred = true ∧
                     o.encodedData.length = i.videoData.length ∧
                     ∀ j ∈ o.encodedData, j.all Char.isAlphanum = true

example : Spec.pre { videoData := ["frame1", "frame2", "frame3"] } ∧
          Spec.post { videoData := ["frame1", "frame2", "frame3"] }
                    { encodedData := ["f1", "f2", "f3"], transferred := true } := by
  unfold Spec; decide
