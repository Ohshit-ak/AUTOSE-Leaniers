-- DD-city: Name of the city for the above address; maximum 20 characters alphabetic string
-- checked: False

structure Input where
  city : String

def is_valid_city (s : String) : Prop :=
  s.length ≤ 20 ∧ ∀ i, i < s.length → Char.isAlpha (s[i])

def Spec : Contract Input String where
  pre  := fun i => is_valid_city i.city
  post := fun i o => o = i.city.city

example : Spec.pre ⟨"Aarhus"⟩ ∧ Spec.post ⟨"Aarhus"⟩ "Aarhus" := by
  simp [Spec]
