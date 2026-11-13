import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  number : String
  expire : String
  cvv    : Nat
  deriving DecidableEq, Repr

structure Address where
  street  : String
  city    : String
  state   : String
  zip     : Nat
  country : String
  deriving DecidableEq, Repr

structure Input where
  username   : String
  password   : String
  creditCard : Option CreditCard
  address    : Option Address
  storingCC  : Bool
  deriving DecidableEq, Repr

structure Output where
  username   : String
  password   : String
  creditCard : Option CreditCard
  address    : Option Address
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ ¬i.storingCC
  post := fun i o =>
    (o.creditCard = none ↔ ¬i.storingCC) ∧
    o.username   = i.username ∧
    o.password   = i.password ∧
    o.address    = i.address

example : Spec.pre { username := "testuser", password := "testpass", creditCard := none, address := none, storingCC := false } ∧
          Spec.post { username := "testuser", password := "testpass", creditCard := none, address := none, storingCC := false }
                    { username := "testuser", password := "testpass", creditCard := none, address := none } := by
  unfold Spec; decide
