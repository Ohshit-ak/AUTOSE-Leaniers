-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.
-- checked: None

structure Contract (Input Output : Type) where
  pre  : Input → Prop
  post : Input → Output → Prop

def Spec : Contract (List Nat) (Nat × Nat) where
  pre input := true
  post input output := 
    let (count, total) := output;
    List.length input = count ∧
    input.sum = total

example : Spec (List.ofNat 3) (3, 6) := by
  simp [List.length, List.sum]
