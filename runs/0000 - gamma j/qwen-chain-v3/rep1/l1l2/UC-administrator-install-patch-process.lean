import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.

-- L0 spec

structure Patch where
  version : String
  deriving DecidableEq, Repr

structure Input where
  webStoreVersion : String
  patches         : List Patch
  success         : Bool
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : String
  patches         : List Patch
  success         : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.webStoreVersion ≠ ""
  post := fun i o => o.webStoreVersion = i.webStoreVersion ∧
                     o.success = true ∧
                     o.patches = i.patches

example : Spec.pre { webStoreVersion := "1.0.0", patches := [], success := true } ∧
          Spec.post { webStoreVersion := "1.0.0", patches := [], success := true }
                    { webStoreVersion := "1.0.0", patches := [], success := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  webStoreVersion : String
  patches         : List Patch
  deriving DecidableEq, Repr

def CheckVersionContract : Contract Input Mid where
  pre  := fun i => i.webStoreVersion ≠ ""
  post := fun i m => m.webStoreVersion = i.webStoreVersion ∧ m.patches = i.patches ∧ m.success = i.success

def ApplyPatchesContract : Contract Mid Output where
  pre  := fun m => m.success
  post := fun m o => o.webStoreVersion = m.webStoreVersion ∧ o.patches = m.patches ∧ o.success = m.success
