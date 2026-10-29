-- DD-credit-card-expiry-date: The date on the credit card when it will get expired; format MM/YY
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

inductive ExpiryDate : String → Prop
| valid (mm : Nat) (yy : Nat) : mm ≤ 12 → yy ≤ 99 → ExpiryDate s

def Spec : Contract String Bool :=
begin
  refine { pre := λ s, ExpiryDate.valid (s[0] - '0') (s[2] - '0'), 
           post := λ s valid, ExpiryDate.valid (s[0] - '0') (s[2] - '0') },
  exact (by decide)
end

example : Spec.pre "12/23" :=
begin
  unfold Spec.pre,
  apply ExpiryDate.valid,
  exact Nat.le_of_add_le_add (by decide) (by decide),
  exact Nat.le_of_add_le_add (by decide) (by decide)
end

example : Spec.post "12/23" true :=
begin
  unfold Spec.post,
  exact true
end
