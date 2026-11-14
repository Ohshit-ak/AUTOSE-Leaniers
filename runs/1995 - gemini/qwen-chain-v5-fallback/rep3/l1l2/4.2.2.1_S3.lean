import ContractForge
open ContractForge

-- 4.2.2.1/S3: This means the video data signals must be encoded digitally and transferred via the WAN to remote sites.

-- L0 spec

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
                     ∀ j ∈ o.encodedData, j ≠ ""

example : Spec.pre { videoData := ["frame1", "frame2", "frame3"] } ∧
          Spec.post { videoData := ["frame1", "frame2", "frame3"] }
                    { transferred := true, encodedData := ["encoded1", "encoded2", "encoded3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { encodedData := x.videoData.filter (fun j => decide (j ≠ "")),
    transferred := true }
