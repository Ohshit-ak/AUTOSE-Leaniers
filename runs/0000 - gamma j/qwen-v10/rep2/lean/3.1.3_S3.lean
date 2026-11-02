import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- compiles: True · rejects_bad_example: True · checked: True

structure CreditCard where
  number : String
  expMonth : Nat
  expYear : Nat
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
  profiles : List CustomerProfile
  deriving DecidableEq, Repr

structure Output where
  profiles : List CustomerProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.profiles.Nodup
  post := fun i o => o.profiles = i.profiles ∧
                     (∀ p ∈ o.profiles, p.name ≠ "" ∧ p.email ≠ "" ∧ p.creditCards.Nodup ∧ p.addresses.Nodup)

example : Spec.pre { profiles := [{ name := "Alice", email := "alice@example.com",
                                     creditCards := [{ number := "1234567890123456", expMonth := 12, expYear := 23, cvv := 123 }],
                                     addresses := [{ street := "123 Main St", city := "Anytown", state := "CA", zip := "12345" }] },
                                   { name := "Bob", email := "bob@example.com",
                                     creditCards := [{ number := "6543210987654321", expMonth := 11, expYear := 24, cvv := 456 }],
                                     addresses := [{ street := "456 Elm St", city := "Othertown", state := "NY", zip := "67890" }] }] } ∧
          Spec.post { profiles := [{ name := "Alice", email := "alice@example.com",
                                     creditCards := [{ number := "1234567890123456", expMonth := 12, expYear := 23, cvv := 123 }],
                                     addresses := [{ street := "123 Main St", city := "Anytown", state := "CA", zip := "12345" }] },
                                   { name := "Bob", email := "bob@example.com",
                                     creditCards := [{ number := "6543210987654321", expMonth := 11, expYear := 24, cvv := 456 }],
                                     addresses := [{ street := "456 Elm St", city := "Othertown", state := "NY", zip := "67890" }] }] }
                    { profiles := [{ name := "Alice", email := "alice@example.com",
                                     creditCards := [{ number := "1234567890123456", expMonth := 12, expYear := 23, cvv := 123 }],
                                     addresses := [{ street := "123 Main St", city := "Anytown", state := "CA", zip := "12345" }] },
                                   { name := "Bob", email := "bob@example.com",
                                     creditCards := [{ number := "6543210987654321", expMonth := 11, expYear := 24, cvv := 456 }],
                                     addresses := [{ street := "456 Elm St", city := "Othertown", state := "NY", zip := "67890" }] }] } := by
  unfold Spec; decide
