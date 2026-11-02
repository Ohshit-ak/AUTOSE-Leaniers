import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: True · checked: True

structure Patch where
  version : String
  deriving DecidableEq, Repr

structure Input where
  webStoreVersion : String
  patches         : List Patch
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : String
  patches         : List Patch
  success         : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.webStoreVersion ≠ ""
  post := fun i o => (o.webStoreVersion = i.webStoreVersion ∧ o.success = true) ∧
                     (o.patches.length ≥ i.patches.length) ∧
                     (o.success = true ↔ o.webStoreVersion ≠ "")

example : Spec.pre { webStoreVersion := "a", patches := [{ version := "1.0.1" }] } ∧ Spec.post { webStoreVersion := "a", patches := [{ version := "1.0.1" }] } { webStoreVersion := "a", patches := [{ version := "1.0.1" }], success := true } := by
  unfold Spec; decide
