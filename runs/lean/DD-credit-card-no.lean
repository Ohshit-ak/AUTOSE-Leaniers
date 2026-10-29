-- DD-credit-card-no: Credit card number of the customer; 16 digit numeric string
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

def CreditCardNo : Type := String
def validCreditCardNo (ccn : CreditCardNo) : Prop :=
  ccn.length = 16 ∧ ccn.all (fun c => c ∈ '0' '1' '2' '3' '4' '5' '6' '7' '8' '9')

def Spec : Contract CreditCardNo Bool :=
  { pre := fun ccn => ccn.length = 16,
    post := fun ccn valid => validCreditCardNo ccn }

example (ccn : CreditCardNo) (h : ccn.length = 16) (h' : ccn.all (fun c => c ∈ '0' '1' '2' '3' '4' '5' '6' '7' '8' '9')) :
  Spec.pre ccn ∧ Spec.post ccn (validCreditCardNo ccn) :=
by
  simp [Spec.pre, Spec.post, validCreditCardNo]
  exact And.intro h h'
