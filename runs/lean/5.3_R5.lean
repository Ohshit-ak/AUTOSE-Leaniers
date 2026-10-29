-- 5.3/R5: The system shall detect consecutive failed login attempts.
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure LoginAttempt (username : String) where
  attemptTime : Date
  success     : Bool

def Spec : Contract (List LoginAttempt) Bool where
  pre ls := true
  post ls detected := 
    let failed := List.filter (fun x => x.success = false) ls
    failed.length ≥ 3 → detected

example : Spec (List.empty LoginAttempt) true :=
  begin
    unfold Spec,
    simp,
    exact true
  end
