import ContractForge
open ContractForge

-- DD-city: Name of the city for the above address; maximum 20 characters alphabetic string

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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 20 ∧
     i.raw.toList.all (·.isAlpha) = true)

example : Spec.pre { raw := "Springfield" } ∧
          Spec.post { raw := "Springfield" } { valid := true } := by
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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 20 ∧
     i.raw.toList.all (·.isAlpha) = true)

-- Component 1: Check the length of the input string
def LengthCheckContract : Contract Input Input where
  pre  := fun i => 1 ≤ i.raw.length ∧ i.raw.length ≤ 20
  post := fun i i' => i' = i

-- Component 2: Check if all characters in the input string are alphabetic
def AlphaCheckContract : Contract Input Output where
  pre  := fun i => LengthCheckContract.post i i
  post := fun i o => o.valid = true ↔ i.raw.toList.all (·.isAlpha) = true

-- Prove PO1: LengthCheckContract's assumption follows from Spec's guarantee
example : Contract.Compatible Spec.post LengthCheckContract.pre := by
  unfold Spec.post LengthCheckContract.pre; simp; discharge_po

-- Prove PO2: The composition of the contracts refines the spec
example : Contract.Refines (Spec.post.seq AlphaCheckContract.post) Spec.post := by
  unfold Spec.post AlphaCheckContract.post; simp; discharge_po