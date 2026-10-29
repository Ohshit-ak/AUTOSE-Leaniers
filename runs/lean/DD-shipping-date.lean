-- DD-shipping-date: Date when the specified order is shipped; format MM/DD/YYYY
-- checked: None

structure Date where
  day : Nat
  month : Nat
  year : Nat
  valid : (month ≤ 12) ∧ (day ≤ 31) ∧ (year ≥ 2000)

def Spec : Contract String Date where
  pre s := 
    match s.split '/' with
    | [m, d, y] := 
      let month' := Nat.ofNat? m
      let day' := Nat.ofNat? d
      let year' := Nat.ofNat? y
      month' ≠ none ∧ day' ≠ none ∧ year' ≠ none ∧
      (match (month', day', year') with
        | (some m, some d, some y) := (m ≤ 12) ∧ (d ≤ 31) ∧ (y ≥ 2000)
        | _ := false)
    | _ := false
  post s d := 
    pre s ∧ d.valid

example : Spec "12/31/2020" (Date.mk 31 12 2020 (by simp)) :=
begin
  unfold pre post,
  simp,
  exact true
end
