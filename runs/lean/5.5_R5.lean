-- 5.5/R5: The system shall validate email address existence.
-- checked: None

structure Email where
  address : String

structure Contract (α : Type) where
  pre  : α → Prop
  post : α → Bool → Prop

def Spec : Contract (List Email) Bool :=
  { pre := λ es, es ≠ []
    , post := λ es res, 
      begin
        cases es with e es,
        unfold res,
        cases e.address with addr,
        -- Assume we have a function checkEmail that returns true if the email exists
        let exists := checkEmail addr,
        -- The postcondition is that the result is true if the email exists, false otherwise
        exact exists
      end }

-- Example showing a witness
example : Spec (List.mkPair [Email.mk "test@example.com"]) true :=
  begin
    unfold Spec,
    unfold checkEmail, -- Assume checkEmail is defined elsewhere
    unfold exists, -- Assume exists is defined as the result of checkEmail
    exact true
  end
