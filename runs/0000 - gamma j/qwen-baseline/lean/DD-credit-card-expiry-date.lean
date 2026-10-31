-- DD-credit-card-expiry-date: The date on the credit card when it will get expired; format MM/YY
-- checked: False

structure Input where
  rawExpiryDate : String

structure Output where
  expiryDateValid : Bool

def Spec : Contract Input Output where
  pre  := fun i => i.rawExpiryDate.length = 5 ∧
                  i.rawExpiryDate[0] ∈ '0' ''9' ∧
                  i.rawExpiryDate[1] ∈ '0' ''9' ∧
                  i.rawExpiryDate[2] = '/' ∧
                  i.rawExpiryDate[3] ∈ '0' ''9' ∧
                  i.rawExpiryDate[4] ∈ '0' ''9'
  post := fun i o => o.expiryDateValid = true ↔ Spec.pre i

example : Spec.pre ⟨"12/23"⟩ ∧ Spec.post ⟨"12/23"⟩ ⟨true⟩ := by
  simp [Spec]
  constructor
  · simp
  · simp
