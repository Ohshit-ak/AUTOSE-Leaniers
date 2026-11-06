import ContractForge
open ContractForge

-- DD-item-id: ID that uniquely identified the selected item; a 7-digit system generated alphanumeric character

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
    (i.raw.length = 7) ∧
    i.raw.toList.all (·.isAlphanum) = true

example : Spec.pre { raw := "A1B2C3D" } ∧
          Spec.post { raw := "A1B2C3D" } { valid := true } := by
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
    (i.raw.length = 7) ∧
    i.raw.toList.all (·.isAlphanum) = true

-- Component 1: Check the length of the input string
def LengthCheckContract : Contract Input Input where
  pre  := fun i => i.raw.length = 7
  post := fun i i' => i' = i

-- Component 2: Check if all characters in the input string are alphanumeric
def AlphanumericCheckContract : Contract Input Output where
  pre  := fun i => i.raw.length = 7
  post := fun i o => o.valid = true ↔
    i.raw.toList.all (·.isAlphanum) = true

-- Prove PO1: LengthCheckContract's assumption follows from Spec's guarantee
example : Contract.Compatible Spec LengthCheckContract := by
  unfold LengthCheckContract Spec; discharge_po

-- Prove PO2: The composition of the two contracts refines the spec
example : Contract.Refines (LengthCheckContract.seq AlphanumericCheckContract) Spec := by
  unfold LengthCheckContract AlphanumericCheckContract Spec; discharge_po

-- Prove PO1: AlphanumericCheckContract's assumption follows from LengthCheckContract's guarantee
example : Contract.Compatible LengthCheckContract AlphanumericCheckContract := by
  unfold LengthCheckContract AlphanumericCheckContract; discharge_po

-- Prove PO2: The composition of the two contracts refines the spec
example : Contract.Refines (LengthCheckContract.seq AlphanumericCheckContract) Spec := by
  unfold LengthCheckContract AlphanumericCheckContract Spec; discharge_po