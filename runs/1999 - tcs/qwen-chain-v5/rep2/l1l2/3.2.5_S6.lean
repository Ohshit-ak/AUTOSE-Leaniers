import ContractForge
open ContractForge

-- 3.2.5/S6: Where applicable, TCS data burst messages shall comply with Variable Message Formats. [SSS215] The TCS shall export and disseminate formatted NITF 2.0 files [SSS558], digital imagery (if applicable) [SSS218], RS-170A video (with as well as without overlay) [SSS219], and tactical communication messages [SSS220].

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { compliant := true,
    nits := ["NITF201"],
    imagery := ["IMAGE1"],
    video := ["RS170A", "RS170A_OVERLAY"],
    messages := ["COMM1"] }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
