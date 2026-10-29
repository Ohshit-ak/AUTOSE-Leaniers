-- 5.3/R3: The system shall encrypt all customer data in database.
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure CustomerData where
  name : String
  email : String
  address : String

def encrypt (data : CustomerData) : CustomerData :=
  { name := "encrypted_" ++ data.name,
    email := "encrypted_" ++ data.email,
    address := "encrypted_" ++ data.address }

def Spec : Contract (List CustomerData) (List CustomerData) where
  pre data := true
  post data enc_data := List.Pairwise (· ≤ ·) data ∧ List.Perm data enc_data ∧ enc_data.forall (·.name).has_prefix "encrypted_" ∧ enc_data.forall (·.email).has_prefix "encrypted_" ∧ enc_data.forall (·.address).has_prefix "encrypted_"

example : Spec := by
  let original_data := [CustomerData.mk "John" "john@example.com" "123 Main St"]
  let encrypted_data := [encrypt original_data.head]
  have h1 := List.Perm.intro original_data.head encrypted_data.head (by simp)
  have h2 := List.Perm.trans h1 (List.perm_singleton _)
  have h3 := List.Perm.trans h2 (List.perm_singleton _)
  have h4 := List.Perm.intro original_data.head encrypted_data.head (by simp)
  have h5 := List.Perm.trans h4 (List.perm_singleton _)
  have h6 := List.Perm.trans h5 (List.perm_singleton _)
  exact { pre := fun _ => true, post := fun _ _ => h6 }
