import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  number : String
  expDate : String
  cvv : Nat
  deriving DecidableEq, Repr

structure Address where
  street : String
  city : String
  state : String
  zip : String
  deriving DecidableEq, Repr

structure CustomerProfile where
  name : String
  email : String
  creditCards : List CreditCard
  addresses : List Address
  deriving DecidableEq, Repr

structure Input where
  profile : CustomerProfile
  checkPaymentInfo : Bool
  deriving DecidableEq, Repr

structure Output where
  profile : CustomerProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.profile.name ≠ "" ∧ i.profile.email ≠ "" ∧ i.checkPaymentInfo = false
  post := fun i o => o.profile = i.profile ∧
                     (o.profile.creditCards = [] ↔ i.checkPaymentInfo = false) ∧
                     (o.profile.addresses = i.profile.addresses)

example : Spec.pre { profile := { name := "John Doe", email := "john@example.com", creditCards := [], addresses := [] }, checkPaymentInfo := false } ∧
          Spec.post { profile := { name := "John Doe", email := "john@example.com", creditCards := [], addresses := [] }, checkPaymentInfo := false }
                    { profile := { name := "John Doe", email := "john@example.com", creditCards := [], addresses := [] } } := by
  unfold Spec; decide
