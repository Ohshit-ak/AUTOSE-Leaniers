import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: None · checked: False

structure Patch where
  version : String
  deriving DecidableEq, Repr

structure Input where
  webStoreVersion : String
  patches         : List Patch
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : String
  patchInstalled  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.patches.Nodup
  post := fun i o => o.webStoreVersion = i.webStoreVersion ∧
                     o.patchInstalled = true ∧
                     ∃ p ∈ i.patches, o.webStoreVersion = p.version

example : Spec.pre { webStoreVersion := "1.0.0", patches := [{ version := "1.0.1" }] } ∧
          Spec.post { webStoreVersion := "1.0.1", patches := [{ version := "1.0.1" }] }
                    { webStoreVersion := "1.0.1", patchInstalled := true } := by
  unfold Spec; decide
