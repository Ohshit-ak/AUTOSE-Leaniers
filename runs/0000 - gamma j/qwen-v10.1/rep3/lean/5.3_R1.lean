import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.
-- compiles: False · rejects_bad_example: None · checked: False

structure CreditCard where
  number : String
  cvv    : String
  expiry : String
  deriving DecidableEq, Repr

structure Input where
  cards : List CreditCard
  deriving DecidableEq, Repr

structure Output where
  valid : List CreditCard
  fraud : List CreditCard
  deriving DecidableEq, Repr

-- A credit card is valid if its number, CVV, and expiry date are all non-empty
-- and the CVV and expiry date are of the correct format.
def ValidCard (c : CreditCard) : Bool :=
  c.number ≠ "" ∧
  c.cvv ≠ "" ∧
  c.expiry ≠ "" ∧
  c.cvv.toList.all Char.isDigit = true ∧
  c.expiry.toList.all (fun c => c.isDigit ∨ c == '/') = true

def Spec : Contract Input Output where
  pre  := fun i => i.cards.Nodup
  post := fun i o => o.valid.length + o.fraud.length = i.cards.length ∧
                     (∀ c ∈ o.valid, ValidCard c) ∧
                     (∀ c ∈ o.fraud, ¬ValidCard c)

example : Spec.pre { cards := [{ number := "1234567890123456", cvv := "123", expiry := "12/23" },
                               { number := "6543210987654321", cvv := "456", expiry := "03/24" }] } ∧
          Spec.post { cards := [{ number := "1234567890123456", cvv := "123", expiry := "12/23" },
                                { number := "6543210987654321", cvv := "456", expiry := "03/24" }] }
                    { valid := [{ number := "1234567890123456", cvv := "123", expiry := "12/23" }],
                                 fraud := [{ number := "6543210987654321", cvv := "456", expiry := "03/24" }] } := by
  unfold Spec; decide
