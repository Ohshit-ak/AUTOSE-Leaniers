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
  storeCreditCards : Bool
  deriving DecidableEq, Repr

structure Output where
  profile : CustomerProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.profile.name ≠ "" ∧ i.profile.email ≠ ""
  post := fun i o => (o.profile.creditCards = [] ↔ i.storeCreditCards = false) ∧
                     (o.profile.addresses = i.profile.addresses) ∧
                     (o.profile.name = i.profile.name) ∧
                     (o.profile.email = i.profile.email)

example : Spec.pre { profile := { name := "John Doe", email := "john.doe@example.com",
                                   creditCards := [], addresses := [] },
                     storeCreditCards := false } ∧
          Spec.post { profile := { name := "John Doe", email := "john.doe@example.com",
                                   creditCards := [], addresses := [] },
                      storeCreditCards := false }
                    { profile := { name := "John Doe", email := "john.doe@example.com",
                                   creditCards := [], addresses := [] } } := by
  unfold Spec; decide
