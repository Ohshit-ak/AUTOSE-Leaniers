import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.
-- compiles: True · rejects_bad_example: None · checked: True

structure CreditCard where
  number : String
  cvv    : Nat
  expiry : String
  deriving DecidableEq, Repr

structure Address where
  street  : String
  city    : String
  state   : String
  zipCode : Nat
  deriving DecidableEq, Repr

structure CustomerProfile where
  name        : String
  email       : String
  creditCards : List CreditCard
  addresses   : List Address
  deriving DecidableEq, Repr

structure Input where
  profiles : List CustomerProfile
  deriving DecidableEq, Repr

structure Output where
  profiles : List CustomerProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.profiles.all (fun p => p.name ≠ "" ∧ p.email ≠ "" ∧ p.creditCards.Nodup ∧ p.addresses.Nodup)
  post := fun i o => o.profiles = i.profiles ∧
                     (∀ p ∈ o.profiles, p.name ≠ "" ∧ p.email ≠ "" ∧ p.creditCards.Nodup ∧ p.addresses.Nodup)

example : Spec.pre { profiles := [{ name := "Alice", email := "alice@example.com",
                                     creditCards := [{ number := "1234567890123456", cvv := 123, expiry := "12/23" }],
                                     addresses := [{ street := "123 Main St", city := "City", state := "State", zipCode := 12345 }] }] } ∧
          Spec.post { profiles := [{ name := "Alice", email := "alice@example.com",
                                     creditCards := [{ number := "1234567890123456", cvv := 123, expiry := "12/23" }],
                                     addresses := [{ street := "123 Main St", city := "City", state := "State", zipCode := 12345 }] }] }
                    { profiles := [{ name := "Alice", email := "alice@example.com",
                                     creditCards := [{ number := "1234567890123456", cvv := 123, expiry := "12/23" }],
                                     addresses := [{ street := "123 Main St", city := "City", state := "State", zipCode := 12345 }] }] } := by
  unfold Spec; decide
