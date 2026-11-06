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

-- L1 architect (success=True)

structure Mid where
  profiles : List CustomerProfile
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => m.profiles = i.profiles ∧
                     ∀ p ∈ m.profiles, p.name ≠ "" ∧
                     p.email ≠ "" ∧
                     p.creditCards.Nodup ∧
                     p.addresses.Nodup

def ComputeContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => o.profiles = m.profiles

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  discharge_po [ComputeContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  discharge_po [ComputeContract, Spec, ValidateContract]

-- L2 ValidateContract (success=False)

def ValidateContractImpl (i : Input) : Mid := { profiles := i.profiles }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  unfold ValidateContract; simp_all

-- L2 ComputeContract (success=True)

def ComputeContractImpl (m : Mid) : Output := { profiles := m.profiles }

theorem ComputeContractImpl_ok : ComputeContract.Satisfies ComputeContractImpl := by
  discharge_po [ComputeContract, ComputeContractImpl, Spec, ValidateContract]