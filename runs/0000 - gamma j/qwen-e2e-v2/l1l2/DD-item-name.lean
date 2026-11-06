import ContractForge
open ContractForge

-- DD-item-name: Name of the selected item; maximum 50 character alphabetic string

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
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 50 ∧
     i.raw.toList.all (·.isAlpha) = true)

example : Spec.pre { raw := "exampleName" } ∧
          Spec.post { raw := "exampleName" } { valid := true } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  raw : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => m.raw.length ≥ 1 ∧ m.raw.length ≤ 50 ∧
                     m.raw.toList.all (·.isAlpha) = true

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.raw.length ≥ 1
  post := fun m o => o.valid = true ∧
                     o.valid ↔
                     (1 ≤ m.raw.length ∧ m.raw.length ≤ 50 ∧
                      m.raw.toList.all (·.isAlpha) = true)

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  split
  · exact h.2.1
  · exact h.2.2

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨h1, h2⟩, ho⟩
  simp only at *
  rw [ho, h1, h2]