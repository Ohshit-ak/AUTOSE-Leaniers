import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- compiles: False · rejects_bad_example: None · checked: False

structure CreditCard where
  number : String
  cvv    : Nat
  expiry : String
  deriving DecidableEq, Repr

structure Address where
  street  : String
  city    : String
  zipCode : Nat
  country : String
  deriving DecidableEq, Repr

structure Input where
  username   : String
  password   : String
  creditCard : Option CreditCard
  address    : Option Address
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.signedIn = true ↔
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
    (o.signedIn = false → i.creditCard.isNone ∧ i.address.isNone)

example : Spec.pre { username := "john", password := "pass123" } ∧
          Spec.post { username := "john", password := "pass123" }
                    { signedIn := false } := by
  unfold Spec; decide
