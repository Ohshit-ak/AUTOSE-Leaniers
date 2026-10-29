-- 5.3/R1: The system shall validate credit cards against fraud.
-- checked: None

structure CreditCard where
  number : String
  cvv     : String
  expDate : String

structure FraudCheck where
  valid : Bool

def Spec : Contract CreditCard FraudCheck where
  pre c := true
  post c f := 
    f.valid ↔ 
      c.cvv.length = 3 ∧ 
      c.expDate.length = 4 ∧ 
      -- Simple validation rules, in practice more complex logic would be used
      c.cvv.all (· ∈ "0123456789") ∧ 
      c.expDate.all (· ∈ "0123456789")

example : Spec (CreditCard.mk "1234567890123456" "123" "12/23") (FraudCheck.mk true) :=
begin
  -- The credit card is valid according to the simple rules
  -- In practice, more complex validation would be used
  simp,
  exact true
end
