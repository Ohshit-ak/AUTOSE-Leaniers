-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- checked: True

structure Input where
  webStoreVersion : Nat
  patchVersion    : Nat
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : Nat
  patchInstalled  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.patchVersion > i.webStoreVersion
  post := fun i o => o.patchInstalled = true ∧
                     o.webStoreVersion = i.patchVersion ∧
                     o.webStoreVersion > i.webStoreVersion

example : Spec.pre { webStoreVersion := 1, patchVersion := 2 } ∧
          Spec.post { webStoreVersion := 1, patchVersion := 2 }
                    { webStoreVersion := 2, patchInstalled := true } := by
  unfold Spec; decide
