import ContractForge
open ContractForge

-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  cardNumber : String
  expiryDate : String
  cvv        : Nat
  deriving DecidableEq, Repr

structure Input where
  cardNumber : String
  expiryDate : String
  cvv        : Nat
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  failedAttempts : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cardNumber ≠ "" ∧ i.expiryDate ≠ "" ∧ 0 < i.cvv
  post := fun i o => o.valid = true ↔
    (i.failedAttempts + 1 = o.failedAttempts ∧
     i.cardNumber = i.cardNumber ∧
     i.expiryDate = i.expiryDate ∧
     i.cvv = i.cvv)

example : Spec.pre { cardNumber := "1234567890123456", expiryDate := "12/24", cvv := 123, failedAttempts := 0 } ∧
          Spec.post { cardNumber := "1234567890123456", expiryDate := "12/24", cvv := 123, failedAttempts := 0 }
                    { valid := true, failedAttempts := 1 } := by
  unfold Spec; decide
