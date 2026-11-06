import ContractForge
open ContractForge

-- DD-password: Password of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)

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
    (4 ≤ i.raw.length ∧ i.raw.length ≤ 10 ∧
     i.raw.toList.all (·.isAlphanum) = true)

example : Spec.pre { raw := "a1b2" } ∧
          Spec.post { raw := "a1b2" } { valid := true } := by
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
    (4 ≤ i.raw.length ∧ i.raw.length ≤ 10 ∧
     i.raw.toList.all (·.isAlphanum) = true)

-- Component 1: Check length of raw
def LengthCheckContract : Contract Input Input where
  pre  := fun i => 4 ≤ i.raw.length ∧ i.raw.length ≤ 10
  post := fun i1 i2 => i1.raw = i2.raw

-- Component 2: Check if all characters in raw are alphanumeric
def AlphanumericCheckContract : Contract Input Output where
  pre  := fun i => LengthCheckContract.post i i
  post := fun i o => o.valid = true ↔
    i.raw.toList.all (·.isAlphanum) = true

-- Prove PO1: LengthCheckContract's assumption follows from Spec's guarantee
example : Contract.Compatible Spec.post LengthCheckContract.pre := by
  unfold Spec.post LengthCheckContract.pre; simp; discharge_po

-- Prove PO2: LengthCheckContract and AlphanumericCheckContract refine Spec
example : Contract.Refines (LengthCheckContract.seq AlphanumericCheckContract) Spec := by
  unfold LengthCheckContract AlphanumericCheckContract Spec; simp; discharge_po