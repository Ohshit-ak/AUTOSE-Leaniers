import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  patchVersion : Nat
  webStoreState : String
  deriving DecidableEq, Repr

structure Output where
  webStoreState : String
  patchInstalled : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.patchVersion
  post := fun i o => o.patchInstalled = true ∧
                     o.webStoreState = "Updated" ∧
                     o.webStoreState = i.webStoreState

example : Spec.pre { patchVersion := 2, webStoreState := "Updated" } ∧ Spec.post { patchVersion := 2, webStoreState := "Updated" } { webStoreState := "Updated", patchInstalled := true } := by
  unfold Spec; decide
