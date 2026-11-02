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
  deriving DecidableEq, Repr

structure Output where
  validated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.creditCards.Nodup
  post := fun i o => o.validated = true ↔
    ∃ c ∈ i.creditCards, c.cardNumber = "existing" ∧
                         c.expiryDate ≠ "" ∧
                         c.cvv ≠ 0

example : Spec.pre { creditCards := [{ cardNumber := "existing", expiryDate := "12/23", cvv := 123 }] } ∧
          Spec.post { creditCards := [{ cardNumber := "existing", expiryDate := "12/23", cvv := 123 }] }
                    { validated := true } := by
  unfold Spec; decide
