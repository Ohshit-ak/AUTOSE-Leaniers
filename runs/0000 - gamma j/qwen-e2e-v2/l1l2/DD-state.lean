import ContractForge
open ContractForge

-- DD-state: Name of the state for the above city; maximum 20 characters alphabetic string

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

structure Mid where
  raw : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => m.raw.length = i.raw.length ∧
                     1 ≤ m.raw.length ∧ m.raw.length ≤ 20 ∧
                     m.raw.toList.all (·.isAlpha) = true

def ComputeContract : Contract Mid Output where
  pre  := fun m => 1 ≤ m.raw.length ∧ m.raw.length ≤ 20 ∧
                   m.raw.toList.all (·.isAlpha) = true
  post := fun m o => o.valid = true

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  exact h.2.1

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]