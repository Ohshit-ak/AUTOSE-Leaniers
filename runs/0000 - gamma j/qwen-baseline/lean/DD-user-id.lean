-- DD-user-id: User ID of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)
-- checked: False

structure Input where
  raw_user_id : String

structure Output where
  valid : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.raw_user_id.length ≥ 4 ∧ i.raw_user_id.length ≤ 10 ∧
                  i.raw_user_id.all (· ∈ ('a'..'z' : List Char) ∪ ('A'..'Z' : List Char) ∪ ('0'..'9' : List Char))
  post := fun i o => o.valid = true ↔ Spec.pre i

example : Spec.pre ⟨"AB12"⟩ ∧ Spec.post ⟨"AB12"⟩ ⟨true⟩ := by
  simp [Spec]
