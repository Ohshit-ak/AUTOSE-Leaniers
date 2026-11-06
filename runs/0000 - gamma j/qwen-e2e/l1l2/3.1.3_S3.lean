import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.

-- L0 spec

structure CreditCard where
  number : String
  expiry : String
  cvv    : Nat
  deriving DecidableEq, Repr

structure Address where
  street  : String
  city    : String
  state   : String
  zipCode : String
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
  pre  := fun _ => True
  post := fun i o => o.profiles = i.profiles ∧
                     ∀ p ∈ o.profiles, p.name ≠ "" ∧
                     p.email ≠ "" ∧
                     p.creditCards.Nodup ∧
                     p.addresses.Nodup

example : Spec.pre { profiles := [{ name := "Alice", email := "alice@example.com",
                                     creditCards := [{ number := "1234567890123456", expiry := "12/24", cvv := 123 }],
                                     addresses := [{ street := "123 Main St", city := "Anytown", state := "CA", zipCode := "12345" }] }] } ∧
          Spec.post { profiles := [{ name := "Alice", email := "alice@example.com",
                                     creditCards := [{ number := "1234567890123456", expiry := "12/24", cvv := 123 }],
                                     addresses := [{ street := "123 Main St", city := "Anytown", state := "CA", zipCode := "12345" }] }] }
                    { profiles := [{ name := "Alice", email := "alice@example.com",
                                     creditCards := [{ number := "1234567890123456", expiry := "12/24", cvv := 123 }],
                                     addresses := [{ street := "123 Main St", city := "Anytown", state := "CA", zipCode := "12345" }] }] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure CreditCard where
  number : String
  expiry : String
  cvv    : Nat
  deriving DecidableEq, Repr

structure Address where
  street  : String
  city    : String
  state   : String
  zipCode : String
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
  pre  := fun _ => True
  post := fun i o => o.profiles = i.profiles ∧
                     ∀ p ∈ o.profiles, p.name ≠ "" ∧
                     p.email ≠ "" ∧
                     p.creditCards.Nodup ∧
                     p.addresses.Nodup

-- Component 1: Ensure profiles are not empty
def Component1Contract : Contract Input Input := 
  { pre  := fun i => i.profiles ≠ []
    post := fun i i' => i' = i }

-- Component 2: Ensure each profile's name is not empty
def Component2Contract : Contract Input Input := 
  { pre  := fun i => ∀ p ∈ i.profiles, p.name ≠ ""
    post := fun i i' => i' = i }

-- Component 3: Ensure each profile's email is not empty
def Component3Contract : Contract Input Input := 
  { pre  := fun i => ∀ p ∈ i.profiles, p.email ≠ ""
    post := fun i i' => i' = i }

-- Component 4: Ensure each profile's credit cards are unique
def Component4Contract : Contract Input Input := 
  { pre  := fun i => ∀ p ∈ i.profiles, p.creditCards.Nodup
    post := fun i i' => i' = i }

-- Component 5: Ensure each profile's addresses are unique
def Component5Contract : Contract Input Input := 
  { pre  := fun i => ∀ p ∈ i.profiles, p.addresses.Nodup
    post := fun i i' => i' = i }

-- Prove PO1: Each component's assumption follows from its predecessor's guarantee
example : Contract.Compatible Component1Contract Spec := by
  unfold Component1Contract Spec; discharge_po

example : Contract.Compatible Component2Contract Component1Contract := by
  unfold Component2Contract Component1Contract; discharge_po

example : Contract.Compatible Component3Contract Component2Contract := by
  unfold Component3Contract Component2Contract; discharge_po

example : Contract.Compatible Component4Contract Component3Contract := by
  unfold Component4Contract Component3Contract; discharge_po

example : Contract.Compatible Component5Contract Component4Contract := by
  unfold Component5Contract Component4Contract; discharge_po

-- Prove PO2: The composition refines the spec
example : Contract.Refines (Component1Contract.seq Component2Contract.seq Component3Contract.seq Component4Contract.seq Component5Contract) Spec := by
  unfold Component1Contract Component2Contract Component3Contract Component4Contract Component5Contract Spec; discharge_po