import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  username   : String
  password   : String
  creditCard : Option String
  address    : Option String
  deriving DecidableEq, Repr

structure Output where
  signedIn  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => o.signedIn = true ↔
    (i.creditCard.isSome ∧ i.address.isSome)

example : Spec.pre { username := "john", password := "pass123", creditCard := some "1234567890123456", address := some "123 Main St" } ∧
          Spec.post { username := "john", password := "pass123", creditCard := some "1234567890123456", address := some "123 Main St" }
                    { signedIn := true } := by
  unfold Spec; decide
