import ContractForge
open ContractForge

-- DD-zip-code: The postal code of the above address; 5 digit numeric string

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
    (i.raw.length = 5 ∧
     i.raw.toList.all (·.isDigit) = true)

example : Spec.pre { raw := "12345" } ∧
          Spec.post { raw := "12345" } { valid := true } := by
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
    (i.raw.length = 5 ∧
     i.raw.toList.all (·.isDigit) = true)

-- Component 1: Check the length of the input string
def LengthCheckContract : Contract Input Input where
  pre  := fun i => i.raw.length = 5
  post := fun i i' => i' = i

-- Component 2: Check if all characters in the input string are digits
def DigitCheckContract : Contract Input Output where
  pre  := fun i => i.raw.length = 5
  post := fun i o => o.valid = true ↔
    i.raw.toList.all (·.isDigit) = true

-- Prove PO1: LengthCheckContract's assumption follows from Spec's guarantee
example : Contract.Compatible Spec.pre LengthCheckContract.pre := by
  unfold Spec LengthCheckContract; simp; discharge_po

-- Prove PO1: DigitCheckContract's assumption follows from LengthCheckContract's guarantee
example : Contract.Compatible LengthCheckContract.post DigitCheckContract.pre := by
  unfold LengthCheckContract DigitCheckContract; simp; discharge_po

-- Prove PO2: The composition of the contracts refines the spec
example : Contract.Refines (Spec.pre.seq LengthCheckContract.pre).seq DigitCheckContract.post Spec.post := by
  unfold Spec LengthCheckContract DigitCheckContract; simp; discharge_po