-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.
-- checked: True

structure Input where
  plug_in_name : String

structure Output where
  removed : Bool

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.removed = true

example : Spec.pre ⟨"plugin1"⟩ ∧ Spec.post ⟨"plugin1"⟩ ⟨true⟩ := by
  simp [Spec]
