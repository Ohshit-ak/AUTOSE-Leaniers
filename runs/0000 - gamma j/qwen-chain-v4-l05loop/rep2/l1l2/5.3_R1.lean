import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.

-- L0 spec

structure CreditCard where
  number : String
  expMonth : Nat
  expYear : Nat
  cvv : Nat
  deriving DecidableEq, Repr

structure Input where
  card : CreditCard
  isFraudulent : Bool
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  reason : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.card.expMonth ≤ 12 ∧ i.card.expYear ≥ 2023
  post := fun i o => (o.valid = true ↔
    i.card.expMonth = 12 ∧ i.card.expYear = 2023 ∧
    (i.card.expMonth < 12 ∨ i.card.expYear > 2023) →
    o.reason = "Card expired" ∨ o.reason = "Future date") ∧
    (o.valid = false ↔
    (i.card.expMonth = 12 ∧ i.card.expYear = 2023) ∧
    i.isFraudulent = true)

example : Spec.pre { card := { number := "1234567890123456", expMonth := 12, expYear := 2023, cvv := 123 }, isFraudulent := false } ∧ Spec.post { card := { number := "1234567890123456", expMonth := 12, expYear := 2023, cvv := 123 }, isFraudulent := false } { valid := true, reason := "Card expired" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  reason : String
  isFraudulent : Bool
  deriving DecidableEq, Repr

def CheckExpirationContract : Contract Input Mid where
  pre  := fun i => i.card.expMonth ≤ 12 ∧ i.card.expYear ≥ 2023
  post := fun i m => (m.reason = "Card expired" ∨ m.reason = "Future date") ↔
    (i.card.expMonth = 12 ∧ i.card.expYear = 2023 ∧
    (i.card.expMonth < 12 ∨ i.card.expYear > 2023)) ∧
    m.isFraudulent = i.isFraudulent

def ValidateCreditCardContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.valid = true ↔ m.reason = "Card expired") ∧
                     (o.valid = false ↔ m.reason = "Future date" ∧ m.isFraudulent)

theorem po1 : Contract.Compatible CheckExpirationContract ValidateCreditCardContract := by
  discharge_po1 [CheckExpirationContract, ValidateCreditCardContract, Spec]

theorem po2 : Contract.Refines (CheckExpirationContract.seq ValidateCreditCardContract) Spec := by
  discharge_po2 [CheckExpirationContract, ValidateCreditCardContract, Spec]

-- L2 CheckExpirationContract (success=False)

def CheckExpirationContractImpl (x : Input) : Mid :=
  { reason := if x.card.expMonth = 12 ∧ x.card.expYear = 2023 ∧ (x.card.expMonth < 12 ∨ x.card.expYear > 2023) then "Card expired" else "Future date",
    isFraudulent := x.isFraudulent }

-- L2 ValidateCreditCardContract (success=False)

def ValidateCreditCardContractImpl (x : Mid) : Output :=
  { valid := x.reason = "Card expired", reason := x.reason }
