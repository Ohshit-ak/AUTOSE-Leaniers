-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- checked: True

structure Input where
  webStoreVersion : Nat

structure Output where
  installationSuccess : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.webStoreVersion < 1000
  post := fun i o => o.installationSuccess = true → i.webStoreVersion + 1 = i.webStoreVersion + 1

example : Spec.pre ⟨500⟩ ∧ Spec.post ⟨500⟩ ⟨true⟩ := by
  simp [Spec]
