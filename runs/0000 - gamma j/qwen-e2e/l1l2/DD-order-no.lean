import ContractForge
open ContractForge

-- DD-order-no: Unique confirmation number of the order to the customer; 9 characters alphanumeric

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
    (i.raw.length = 9) ∧
    (i.raw.toList.all Char.isAlphanum = true)

example : Spec.pre { raw := "A1B2C3D4E" } ∧
          Spec.post { raw := "A1B2C3D4E" }
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
    (i.raw.length = 9) ∧
    (i.raw.toList.all Char.isAlphanum = true)

-- Component 1: Check the length of the input string
def LengthCheckContract : Contract Input Input where
  pre  := fun i => i.raw.length = 9
  post := fun i i' => i' = i

-- Component 2: Check if the input string is alphanumeric
def AlphanumericCheckContract : Contract Input Output where
  pre  := fun i => i.raw.length = 9
  post := fun i o => o.valid = true ↔
    i.raw.toList.all Char.isAlphanum = true

-- Prove PO1: LengthCheckContract's assumption follows from Spec's guarantee
example : Contract.Compatible Spec.LengthCheckContract := by
  unfold Contract.Compatible; intros i; simp [Spec.post, LengthCheckContract.pre, LengthCheckContract.post]; discharge_po

-- Prove PO2: The composition of the two contracts refines the spec
example : Contract.Refines (Spec.LengthCheckContract.seq Spec.AlphanumericCheckContract) Spec := by
  unfold Contract.Refines; intros i o; simp [Spec.post, LengthCheckContract.post, AlphanumericCheckContract.post]; discharge_po

-- Define the final contract
def FinalContract : Contract Input Output := Spec.LengthCheckContract.seq Spec.AlphanumericCheckContract