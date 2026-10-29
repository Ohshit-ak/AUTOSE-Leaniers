-- DD-shipping-price: Cost for shipping the item to its destination; in dollars and cents
-- checked: None

structure MoneyCents where
  value : Nat
  deriving Inhabited

def isMoneyCents (n : Nat) : Prop := 
  n ≤ 99

def Spec : Contract Nat MoneyCents where
  pre n := isMoneyCents n
  post n m := m.value = n ∧ isMoneyCents n

example : Spec 45 45 := by
  simp
  exact ⟨ rfl , isMoneyCents 45 ⟩
