import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: None · checked: True

structure Patch where
  version : String
  deriving DecidableEq, Repr

structure WebStore where
  version : String
  deriving DecidableEq, Repr

structure Input where
  currentVersion : WebStore
  patches : List Patch
  deriving DecidableEq, Repr

structure Output where
  updatedVersion : WebStore
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.patches.length > 0
  post := fun i o => o.success ↔
    (o.updatedVersion.version = i.currentVersion.version ++ " (patched)") ∧
    (i.patches.length = o.updatedVersion.version.length - i.currentVersion.version.length)

example : Spec.pre { currentVersion := { version := "2.0.0" }, patches := [{ version := "2.0.1" }] } ∧ Spec.post { currentVersion := { version := "2.0.0" }, patches := [{ version := "2.0.1" }] } { updatedVersion := { version := "2.0.0 (patched)" }, success := false } := by
  unfold Spec; decide
