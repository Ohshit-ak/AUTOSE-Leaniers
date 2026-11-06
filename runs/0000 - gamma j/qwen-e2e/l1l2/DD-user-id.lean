import ContractForge
open ContractForge

-- DD-user-id: User ID of the employee /customer of Tool Co Company; minimum 4 to maximum 10 characters (alphabetic or alphanumeric)

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
    (4 ≤ i.raw.length ∧ i.raw.length ≤ 10) ∧
    i.raw.toList.all Char.isAlphanum = true

example : Spec.pre { raw := "user1" } ∧
          Spec.post { raw := "user1" } { valid := true } := by
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
    (4 ≤ i.raw.length ∧ i.raw.length ≤ 10) ∧
    i.raw.toList.all Char.isAlphanum = true

def LengthContract : Contract Input Input where
  pre  := fun i => 4 ≤ i.raw.length ∧ i.raw.length ≤ 10
  post := fun i i' => i' = i

def AlphanumericContract : Contract Input Output where
  pre  := fun i => i.raw.toList.all Char.isAlphanum
  post := fun i o => o.valid = true

def ValidContract : Contract Input Output where
  pre  := fun i => i.raw.toList.all Char.isAlphanum
  post := fun i o => o.valid = true

-- Prove PO1: LengthContract's assumption follows from Spec's guarantee
example : Contract.Compatible Spec.post LengthContract.pre := by
  unfold Spec.post LengthContract.pre; simp; discharge_po

-- Prove PO1: AlphanumericContract's assumption follows from LengthContract's guarantee
example : Contract.Compatible LengthContract.post AlphanumericContract.pre := by
  unfold LengthContract.post AlphanumericContract.pre; simp; discharge_po

-- Prove PO1: ValidContract's assumption follows from AlphanumericContract's guarantee
example : Contract.Compatible AlphanumericContract.post ValidContract.pre := by
  unfold AlphanumericContract.post ValidContract.pre; simp; discharge_po

-- Prove PO2: The composition refines the spec
example : Contract.Refines (Spec.pre.seq LengthContract.post.seq AlphanumericContract.post.seq ValidContract.post) Spec := by
  unfold Spec.pre LengthContract.post AlphanumericContract.post ValidContract.post; simp; discharge_po