import ContractForge
open ContractForge

-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  cardNumber : String
  expiration  : String
  cvv        : Nat
  deriving DecidableEq, Repr

structure CustomerItem where
  cardNumber : String
  deriving DecidableEq, Repr

structure Customer where
  id         : Nat
  creditCards : List CreditCard
  deriving DecidableEq, Repr

structure Input where
  customerID : Nat
  creditCard : CreditCard
  customer   : List CustomerItem
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerID ≠ 0
  post := fun i o => o.valid = true ↔
    ∃ cc ∈ i.customer, cc.cardNumber = i.creditCard.cardNumber

example : Spec.pre { customerID := 1, creditCard := { cardNumber := "1234567890123456", expiration := "12/24", cvv := 123 },
                     customer := [{ cardNumber := "1234567890123456" }] } ∧
          Spec.post { customerID := 1, creditCard := { cardNumber := "1234567890123456", expiration := "12/24", cvv := 123 },
                      customer := [{ cardNumber := "1234567890123456" }] }
                    { valid := true } := by
  unfold Spec; decide
