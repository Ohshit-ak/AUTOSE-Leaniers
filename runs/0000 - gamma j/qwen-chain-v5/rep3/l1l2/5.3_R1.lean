import ContractForge
open ContractForge

-- 5.3/R1: The system shall validate credit cards against fraud.

-- L0 spec

structure CreditCard where
  number : String
  name   : String
  month  : Nat
  year   : Nat
  cvv    : Nat
  deriving DecidableEq, Repr

structure Input where
  cards : List CreditCard
  deriving DecidableEq, Repr

structure Output where
  valid : List CreditCard
  fraudulent : List CreditCard
  deriving DecidableEq, Repr

-- Define the fraudList as a helper
def fraudList : List (String × Nat × Nat × Nat) := 
  [("1234567890123456", 1, 2023, 123), ("9876543210987654", 2, 2024, 456)]

def Spec : Contract Input Output where
  pre  := fun i => i.cards.length > 0
  post := fun i o => o.valid.length + o.fraudulent.length = i.cards.length ∧
                     (∀ c ∈ o.valid, ¬(c ∈ o.fraudulent)) ∧
                     (∀ c ∈ o.fraudulent, (c.number, c.month, c.year, c.cvv) ∈ fraudList) ∧
                     (∀ c ∈ i.cards, c ∈ o.valid ↔ ¬(c.number, c.month, c.year, c.cvv) ∈ fraudList)

example : Spec.pre { cards := [{ number := "1234567890123456", name := "Alice", month := 1, year := 2023, cvv := 123 },
                                { number := "9876543210987654", name := "Bob", month := 2, year := 2024, cvv := 456 }] } ∧
          Spec.post { cards := [{ number := "1234567890123456", name := "Alice", month := 1, year := 2023, cvv := 123 },
                                 { number := "9876543210987654", name := "Bob", month := 2, year := 2024, cvv := 456 }] }
                    { valid := [], fraudulent := [{ number := "1234567890123456", name := "Alice", month := 1, year := 2023, cvv := 123 },
                                                  { number := "9876543210987654", name := "Bob", month := 2, year := 2024, cvv := 456 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { valid := x.cards.filter (fun c => ¬decide ((c.number, c.month, c.year, c.cvv) ∈ fraudList)),
    fraudulent := x.cards.filter (fun c => decide ((c.number, c.month, c.year, c.cvv) ∈ fraudList)) }
