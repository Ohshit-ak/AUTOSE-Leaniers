import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: None · checked: True

structure Patch where
  version : String
  deriving DecidableEq, Repr

structure Input where
  webStoreVersion : String
  patches         : List Patch
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : String
  success         : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.webStoreVersion ≠ ""
  post := fun i o => o.success = true ↔
    ∃ p ∈ i.patches, p.version > i.webStoreVersion ∧
    o.webStoreVersion = p.version

example : Spec.pre { webStoreVersion := "1.0.0", patches := [{ version := "1.1.0" }] } ∧
          Spec.post { webStoreVersion := "1.0.0", patches := [{ version := "1.1.0" }] }
                    { webStoreVersion := "1.1.0", success := true } := by
  unfold Spec; decide
