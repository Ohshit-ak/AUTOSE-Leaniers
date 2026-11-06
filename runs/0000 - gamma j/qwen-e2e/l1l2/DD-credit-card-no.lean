import ContractForge
open ContractForge

-- DD-credit-card-no: Credit card number of the customer; 16 digit numeric string

-- L0 spec

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    i.raw.length = 16 ∧
    i.raw.toList.all Char.isDigit = true

example : Spec.pre { raw := "1234567890123456" } ∧
          Spec.post { raw := "1234567890123456" }
                    { valid := true } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    i.raw.length = 16 ∧
    i.raw.toList.all Char.isDigit = true

-- Component 1: Check the length of the raw string
def LengthCheckContract : Contract Input Input where
  pre  := fun i => i.raw.length = 16
  post := fun i i' => i' = i

-- Component 2: Check if all characters in the raw string are digits
def DigitCheckContract : Contract Input Output where
  pre  := fun i => i.raw.length = 16
  post := fun i o => o.valid = true ↔
    i.raw.toList.all Char.isDigit = true

-- Prove PO1: LengthCheckContract's assumption follows from Spec's guarantee
example : Contract.Compatible (Spec.post) (LengthCheckContract.pre) := by
  unfold Spec LengthCheckContract; simp; discharge_po

-- Prove PO2: The composition of the two contracts refines the spec
example : Contract.Refines (LengthCheckContract.seq DigitCheckContract) Spec := by
  unfold Spec LengthCheckContract DigitCheckContract; simp; discharge_po

-- Prove PO1: DigitCheckContract's assumption follows from LengthCheckContract's guarantee
example : Contract.Compatible (LengthCheckContract.post) (DigitCheckContract.pre) := by
  unfold LengthCheckContract DigitCheckContract; simp; discharge_po

-- Prove PO2: The composition of the two contracts refines the spec
example : Contract.Refines (DigitCheckContract.seq LengthCheckContract) Spec := by
  unfold Spec LengthCheckContract DigitCheckContract; simp; discharge_po