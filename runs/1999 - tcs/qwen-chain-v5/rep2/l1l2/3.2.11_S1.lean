import ContractForge
open ContractForge

-- 3.2.11/S1: The TCS shall allow authorized operators to install software upgrades via CD-ROM as well as other media storage devices. [SSS276] The TCS shall restrict operator access to this capability via password protection. [SSS277] The TCS shall provide the capability for Authorized Operators to modify all TCS programmable parameters. [SSS278] As a minimum, the TCS shall restrict Operator access to this capability via password protection. [SSS279] The TCS shall be capable of importing National Imagery Mapping Agency (NIMA) Digital Terrain Elevation Data (DTED), Digital Feature Analysis Data (DFAD), Arc Digitized Raster Graphic and scanned hard copy maps, via compact disk. [SSS280] The TCS shall be capable of importing map information via operator procedure [SSS555] and shall be capable of incorporating vector format and Compressed ADRG (CADRG) maps. [SSS281]

-- L0 spec

structure Input where
  operatorPassword : String
  mediaType        : String
  mediaData        : String
  deriving DecidableEq, Repr

structure Output where
  success          : Bool
  message          : String
  deriving DecidableEq, Repr

-- IMPL: Password protection and media handling

def Spec : Contract Input Output where
  pre  := fun i => i.operatorPassword ≠ ""
  post := fun i o => (o.success = true ↔
    i.operatorPassword = "authorized" ∧
    (i.mediaType = "CD-ROM" ∨ i.mediaType = "other storage device") ∧
    (i.mediaData = "NIMA DTED" ∨ i.mediaData = "NIMA DFAD" ∨
     i.mediaData = "Arc Digitized Raster Graphic" ∨ i.mediaData = "scanned hard copy maps" ∨
     i.mediaData = "vector format" ∨ i.mediaData = "Compressed ADRG (CADRG) maps"))

example : Spec.pre { operatorPassword := "authorized", mediaType := "CD-ROM", mediaData := "NIMA DTED" } ∧
          Spec.post { operatorPassword := "authorized", mediaType := "CD-ROM", mediaData := "NIMA DTED" }
                    { success := true, message := "Upgrade installed successfully" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { success := decide (x.operatorPassword = "authorized" ∧
    (x.mediaType = "CD-ROM" ∨ x.mediaType = "other storage device") ∧
    (x.mediaData = "NIMA DTED" ∨ x.mediaData = "NIMA DFAD" ∨
     x.mediaData = "Arc Digitized Raster Graphic" ∨ x.mediaData = "scanned hard copy maps" ∨
     x.mediaData = "vector format" ∨ x.mediaData = "Compressed ADRG (CADRG) maps")),
    message := "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
