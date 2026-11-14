import ContractForge
open ContractForge

-- 3.2.5/S6: Where applicable, TCS data burst messages shall comply with Variable Message Formats. [SSS215] The TCS shall export and disseminate formatted NITF 2.0 files [SSS558], digital imagery (if applicable) [SSS218], RS-170A video (with as well as without overlay) [SSS219], and tactical communication messages [SSS220].

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { compliant := true,
    nits := x.files.filter (· = "NITF 2.0"),
    imagery := x.files.filter (· = "digital imagery"),
    video := x.files.filter (· = "RS-170A video"),
    messages := x.files.filter (· = "tactical communication messages") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
