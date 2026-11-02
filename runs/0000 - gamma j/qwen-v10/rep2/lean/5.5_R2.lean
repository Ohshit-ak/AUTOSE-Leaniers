import ContractForge
open ContractForge

-- 5.5/R2: For returning customers, the system shall validate 'existing' credit card in system after each log in.
-- compiles: True · rejects_bad_example: True · checked: True

structure Card where
  cardNumber : String
  expiryDate : String
  cvv        : String
  deriving DecidableEq, Repr

structure Input where
  cardNumber : String
  expiryDate : String
  cvv        : String
  loggedIn   : Bool
  cards      : List Card
  deriving DecidableEq, Repr

structure Output where
  validated  : Bool
  error      : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.loggedIn = true
  post := fun i o => (o.validated = true ↔
    ∃ cc ∈ i.cards, cc.cardNumber = i.cardNumber ∧
    (cc.expiryDate = i.expiryDate ∧ cc.cvv = i.cvv)) ∧
    (o.validated = false → o.error = some "Invalid credit card information")

example : Spec.pre { cardNumber := "1234567890123456", expiryDate := "12/24", cvv := "123", loggedIn := true,
                     cards := [{ cardNumber := "1234567890123456", expiryDate := "12/24", cvv := "123" }] } ∧
          Spec.post { cardNumber := "1234567890123456", expiryDate := "12/24", cvv := "123", loggedIn := true,
                      cards := [{ cardNumber := "1234567890123456", expiryDate := "12/24", cvv := "123" }] }
                    { validated := true, error := none } := by
  unfold Spec; decide
