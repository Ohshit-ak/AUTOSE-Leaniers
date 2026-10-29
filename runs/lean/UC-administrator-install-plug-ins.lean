-- UC-administrator-install-plug-ins: Install Plug-ins: Install a new plug-in to the application.
-- checked: None

structure Contract (α : Type) where
  pre : α → Prop
  post : α → α → Prop

structure Input where
  installedPlugIns : List String

def Spec : Contract Input Input where
  pre s := true
  post s s' := s'.installedPlugIns = s.installedPlugIns ++ ["newPlugIn"]

example : Spec :=
begin
  -- Initial state
  let s : Input := { installedPlugIns := ["existingPlugIn1", "existingPlugIn2"] },
  -- New state after installing the plug-in
  let s' : Input := { installedPlugIns := ["existingPlugIn1", "existingPlugIn2", "newPlugIn"] },
  -- Check postcondition
  simp [s, s'],
  exact true
end
