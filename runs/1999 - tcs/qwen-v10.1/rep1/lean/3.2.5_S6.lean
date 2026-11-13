import ContractForge
open ContractForge

-- 3.2.5/S6: Where applicable, TCS data burst messages shall comply with Variable Message Formats. [SSS215] The TCS shall export and disseminate formatted NITF 2.0 files [SSS558], digital imagery (if applicable) [SSS218], RS-170A video (with as well as without overlay) [SSS219], and tactical communication messages [SSS220].
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  files : List String
  deriving DecidableEq, Repr

structure Output where
  compliant : Bool
  nits      : List String
  imagery   : List String
  video    : List String
  messages : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.files.length = 2
  post := fun i o => o.compliant = true ∧
    (o.nits.length = i.files.count "NITF 2.0" ∧
     o.imagery.length = i.files.count "digital imagery" ∧
     o.video.length = i.files.count "RS-170A video" ∧
     o.messages.length = i.files.count "tactical communication messages")

example : Spec.pre { files := ["NITF 2.0", "tactical communication messages"] } ∧
          Spec.post { files := ["NITF 2.0", "tactical communication messages"] }
                    { compliant := true, nits := ["NITF 2.0"], imagery := [], video := [], messages := ["tactical communication messages"] } := by
  unfold Spec; decide
