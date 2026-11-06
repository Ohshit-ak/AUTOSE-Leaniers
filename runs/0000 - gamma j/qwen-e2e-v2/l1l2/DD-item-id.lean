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

structure Mid where
  raw : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => m.raw.length = 7 ∧
    m.raw.toList.all (·.isAlphanum) = true

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.raw.length = 7 ∧
    m.raw.toList.all (·.isAlphanum) = true
  post := fun m o => o.valid = true

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  exact h.2

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, fun i o _ ⟨m, ⟨h1, h2⟩, h3⟩ => h3⟩
  simp only at h1 h2
  rw [h1, h2]