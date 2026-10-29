-- DD-city: Name of the city for the above address; maximum 20 characters alphabetic string
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

inductive City : Type
| mk : String → City
with
  max_length : Nat := 20
  charset : Set Char := { c | c ∈ 'a'..'z' }

def is_valid_city (s : String) : Prop :=
  s.length ≤ City.max_length ∧
  s.forall (fun c => c ∈ City.charset)

def Spec : Contract String City :=
  { pre := fun s => is_valid_city s
  , post := fun s c => is_valid_city s ∧ c = City.mk s
  }

example : Spec.pre "NewYork" :=
  by simp [is_valid_city, City.mk, City.max_length, City.charset]

example (c : City) : Spec.post "NewYork" c :=
  by simp [is_valid_city, City.mk, City.max_length, City.charset]
