import ContractForge
open ContractForge

-- 3.2.5/S6: Where applicable, TCS data burst messages shall comply with Variable Message Formats. [SSS215] The TCS shall export and disseminate formatted NITF 2.0 files [SSS558], digital imagery (if applicable) [SSS218], RS-170A video (with as well as without overlay) [SSS219], and tactical communication messages [SSS220].
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  files : List String
  deriving DecidableEq, Repr

structure Output where
  compliant : Bool
  nits       : List String
  imagery    : List String
  video     : List String
  messages  : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.files.length = 2
  post := fun i o => o.compliant = true ∧
    (o.nits.length = 1 ∧ o.nits.contains "NITF201" ∧ o.nits.Nodup) ∧
    (o.imagery.length = 1 ∧ o.imagery.contains "IMAGE1" ∧ o.imagery.Nodup) ∧
    (o.video.length = 2 ∧
      o.video.contains "RS170A" ∧
      o.video.contains "RS170A_OVERLAY" ∧
      o.video.Nodup) ∧
    (o.messages.length = 1 ∧ o.messages.contains "COMM1" ∧ o.messages.Nodup)

example : Spec.pre { files := ["NITF201", "IMAGE1"] } ∧
          Spec.post { files := ["NITF201", "IMAGE1"] }
                    { compliant := true, nits := ["NITF201"], imagery := ["IMAGE1"], video := ["RS170A", "RS170A_OVERLAY"], messages := ["COMM1"] } := by
  unfold Spec; decide
