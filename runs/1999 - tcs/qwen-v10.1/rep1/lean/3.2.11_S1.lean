import ContractForge
open ContractForge

-- 3.2.11/S1: The TCS shall allow authorized operators to install software upgrades via CD-ROM as well as other media storage devices. [SSS276] The TCS shall restrict operator access to this capability via password protection. [SSS277] The TCS shall provide the capability for Authorized Operators to modify all TCS programmable parameters. [SSS278] As a minimum, the TCS shall restrict Operator access to this capability via password protection. [SSS279] The TCS shall be capable of importing National Imagery Mapping Agency (NIMA) Digital Terrain Elevation Data (DTED), Digital Feature Analysis Data (DFAD), Arc Digitized Raster Graphic and scanned hard copy maps, via compact disk. [SSS280] The TCS shall be capable of importing map information via operator procedure [SSS555] and shall be capable of incorporating vector format and Compressed ADRG (CADRG) maps. [SSS281]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  operatorPassword : String
  parameters : List String
  mediaType : String
  mediaData : String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  message : String
  parameters : List String
  deriving DecidableEq, Repr

-- IMPL: Password protection and parameter modification

def Spec : Contract Input Output where
  pre  := fun i => i.operatorPassword ≠ ""
  post := fun i o => o.success ↔
    (i.operatorPassword = "authorized" ∧
     (i.mediaType = "CD-ROM" ∨ i.mediaType = "other") ∧
     (i.mediaType = "CD-ROM" ∨ i.mediaType = "other" ∨ i.mediaType = "scanned") ∧
     (i.mediaType = "CD-ROM" ∨ i.mediaType = "other" ∨ i.mediaType = "scanned" ∨ i.mediaType = "vector" ∨ i.mediaType = "CADRG"))

example : Spec.pre { operatorPassword := "authorized", parameters := [], mediaType := "CD-ROM", mediaData := "data" } ∧
          Spec.post { operatorPassword := "authorized", parameters := [], mediaType := "CD-ROM", mediaData := "data" }
                    { success := true, message := "Upgrade successful", parameters := [] } := by
  unfold Spec; decide
