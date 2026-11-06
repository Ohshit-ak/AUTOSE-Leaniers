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

structure Mid where
  raw : String
  length : Nat
  isAlpha : Bool
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => True
  post := fun i m => m.length = i.raw.length ∧ m.isAlpha = (i.raw.toList.all (·.isAlpha))

def ComputeContract : Contract Mid Output where
  pre  := fun m => 1 ≤ m.length ∧ m.length ≤ 100
  post := fun m o => o.valid = true ∧
    (m.length = i.raw.length ∧ m.isAlpha = (i.raw.toList.all (·.isAlpha)))

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  exact h.2

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hl, hi⟩, ho⟩
  simp only at *
  rw [ho, hl, hi]