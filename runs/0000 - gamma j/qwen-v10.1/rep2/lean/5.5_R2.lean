import ContractForge
open ContractForge

-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  cardNumber : String
  expirationDate : String
  deriving DecidableEq, Repr

structure Input where
  creditCards : List CreditCard
  cardNumber : String
  cardExpirationDate : String
  deriving DecidableEq, Repr

structure Output where
  validated : Bool
  error     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cardNumber ≠ "" ∧ i.cardExpirationDate ≠ ""
  post := fun i o => (o.validated = true ↔
    ∃ c ∈ i.creditCards, c.cardNumber = i.cardNumber ∧ c.expirationDate = i.cardExpirationDate) ∧
                     (o.validated = false → o.error ≠ "")

example : Spec.pre { creditCards := [{ cardNumber := "1234567890123456", expirationDate := "12/23" }],
                     cardNumber := "1234567890123456", cardExpirationDate := "12/23" } ∧
          Spec.post { creditCards := [{ cardNumber := "1234567890123456", expirationDate := "12/23" }],
                      cardNumber := "1234567890123456", cardExpirationDate := "12/23" }
                    { validated := true, error := "" } := by
  unfold Spec; decide
