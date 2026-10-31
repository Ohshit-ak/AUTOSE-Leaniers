-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- checked: False

structure Input where
  plug_in_id : Nat
  new_options : List String

structure Output where
  confirmation : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.plug_in_id < 1000
  post := fun i o => o.confirmation = true → i.new_options ≠ []

example : Spec.pre ⟨1, #["option1", "option2"]⟩ ∧ Spec.post ⟨1, #["option1", "option2"]⟩ ⟨true⟩ := by
  simp [Spec]
