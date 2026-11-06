import ContractForge
open ContractForge

-- DD-text-description: special description of the selected item; maximum 100 alphabetic characters

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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 100 ∧
     i.raw.toList.all (·.isAlpha) = true)

example : Spec.pre { raw := "short description" } ∧ Spec.post { raw := "short description" } { valid := false } := by
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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 100 ∧
     i.raw.toList.all (·.isAlpha) = true)

-- Decompose the spec into two components

def LengthCheckContract : Contract Input Input where
  pre  := fun i => 1 ≤ i.raw.length ∧ i.raw.length ≤ 100
  post := fun i i' => i' = i

def AlphaCheckContract : Contract Input Output where
  pre  := fun i => LengthCheckContract.post i i
  post := fun i o => o.valid = true ↔ i.raw.toList.all (·.isAlpha) = true

-- Prove PO1: each component's assumption follows from its predecessor's guarantee
example : Contract.Compatible LengthCheckContract.post Spec.pre := by
  unfold LengthCheckContract.post Spec.pre; simp; discharge_po

example : Contract.Compatible AlphaCheckContract.post LengthCheckContract.post := by
  unfold AlphaCheckContract.post LengthCheckContract.post; simp; discharge_po

-- Prove PO2: the composition refines the spec
example : Contract.Refines (LengthCheckContract.seq AlphaCheckContract) Spec := by
  unfold LengthCheckContract AlphaCheckContract Spec; simp; discharge_po