-- DD-state: Name of the state for the above city; maximum 20 characters alphabetic string
-- checked: False

structure Input where
  raw_state : String

structure Output where
  state : String

def is_valid_state (s : String) : Prop :=
  s.length ≤ 20 ∧ s.forall (fun c => c = 'a' ∨ c = 'b' ∨ c = 'c' ∨ c = 'd' ∨ c = 'e' ∨ c = 'f' ∨ c = 'g' ∨ c = 'h' ∨ c = 'i' ∨ c = 'j' ∨ c = 'k' ∨ c = 'l' ∨ c = 'm' ∨ c = 'n' ∨ c = 'o' ∨ c = 'p' ∨ c = 'q' ∨ c = 'r' ∨ c = 's' ∨ c = 't' ∨ c = 'u' ∨ c = 'v' ∨ c = 'w' ∨ c = 'x' ∨ c = 'y' ∨ c = 'z')

def Spec : Contract Input Output where
  pre  := fun i => is_valid_state i.raw_state
  post := fun i o => o.state = i.raw_state ∧ is_valid_state o.state

example : Spec.pre ⟨"CityName"⟩ ∧ Spec.post ⟨"CityName"⟩ ⟨"CityName"⟩ := by
  simp [Spec]
