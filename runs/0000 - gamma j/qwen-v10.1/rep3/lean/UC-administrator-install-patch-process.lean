import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: True · checked: True

structure Patch where
  name : String
  version : String
  deriving DecidableEq, Repr

structure Input where
  webStoreVersion : String
  patches : List Patch
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : String
  patchesInstalled : List Patch
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.webStoreVersion ≠ ""
  post := fun i o => o.webStoreVersion = "new-version" ∧
                     o.patchesInstalled.length = 1 ∧
                     o.patchesInstalled = [{ name := "patch", version := "new-version" }] ∧
                     (o.webStoreVersion = "new-version" ↔
                      ∃ p ∈ i.patches, p.name = "patch" ∧ p.version = "new-version")

example : Spec.pre { webStoreVersion := "old-version", patches := [{ name := "patch", version := "new-version" }] } ∧
          Spec.post { webStoreVersion := "old-version", patches := [{ name := "patch", version := "new-version" }] }
                    { webStoreVersion := "new-version", patchesInstalled := [{ name := "patch", version := "new-version" }] } := by
  unfold Spec; decide
