-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- checked: None

structure Contract (α : Type) where
  pre : α → Prop
  post : α → α → Prop

structure SystemState where
  webStoreVersion : String

def Spec : Contract SystemState SystemState where
  pre s := true
  post s s' := s'.webStoreVersion = s.webStoreVersion ++ "-updated"

example : Spec := by
  let s := SystemState.{webStoreVersion := "1.0"}
  let s' := SystemState.{webStoreVersion := "1.0-updated"}
  exact (s, s')
