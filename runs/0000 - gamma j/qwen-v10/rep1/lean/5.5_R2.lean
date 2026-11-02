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
  creditCards : List CreditCard
  cardNumber  : String
  expiryDate  : String
  cvv         : Nat
  deriving DecidableEq, Repr

structure Output where
  valid      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cardNumber ≠ "" ∧ i.expiryDate ≠ "" ∧ 0 < i.cvv
  post := fun i o => o.valid = true ↔
    ∃ cc ∈ i.creditCards, cc.cardNumber = i.cardNumber ∧
                          cc.expiryDate = i.expiryDate ∧
                          cc.cvv = i.cvv

example : Spec.pre { creditCards := [{ cardNumber := "1234567890123456", expiryDate := "12/24", cvv := 123 }],
                     cardNumber := "1234567890123456", expiryDate := "12/24", cvv := 123 } ∧
          Spec.post { creditCards := [{ cardNumber := "1234567890123456", expiryDate := "12/24", cvv := 123 }],
                      cardNumber := "1234567890123456", expiryDate := "12/24", cvv := 123 }
                    { valid := true } := by
  unfold Spec; decide
