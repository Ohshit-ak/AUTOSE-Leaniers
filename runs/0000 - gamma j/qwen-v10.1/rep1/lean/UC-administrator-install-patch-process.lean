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
