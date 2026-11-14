import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: False · rejects_bad_example: None · checked: False

structure Patch where
  version : Nat
  deriving DecidableEq, Repr

structure Input where
  webStoreVersion : Nat
  patches         : List Patch
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : Nat
  patchVersion    : Nat
  success         : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.patches.Nodup
  post := fun i o => o.webStoreVersion = i.webStoreVersion ∧
                     o.patchVersion = i.patches.head.version ∧
                     o.success = true

example : Spec.pre { webStoreVersion := 10, patches := [{ version := 11 }] } ∧
          Spec.post { webStoreVersion := 10, patches := [{ version := 11 }] }
                    { webStoreVersion := 11, patchVersion := 11, success := true } := by
  unfold Spec; decide
