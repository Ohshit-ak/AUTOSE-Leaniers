-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- checked: True

structure Input where
  webStoreVersion : String
  patchVersion    : String
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : String
  patchInstalled   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.webStoreVersion < i.patchVersion
  post := fun i o => o.patchInstalled = true ∧
                     o.webStoreVersion = i.patchVersion ∧
                     o.webStoreVersion ≠ i.webStoreVersion

example : Spec.pre { webStoreVersion := "1.0.0", patchVersion := "1.0.1" } ∧
          Spec.post { webStoreVersion := "1.0.0", patchVersion := "1.0.1" }
                    { webStoreVersion := "1.0.1", patchInstalled := true } := by
  unfold Spec; decide
