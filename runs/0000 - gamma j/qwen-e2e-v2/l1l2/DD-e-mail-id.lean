import ContractForge
open ContractForge

-- DD-e-mail-id: E-mail address of the customer who is using the Web order system; 50 characters alphanumeric

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
    i.raw.length = 50 ∧
    i.raw.toList.all Char.isAlphanum = true

example : Spec.pre { raw := "aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890" } ∧ Spec.post { raw := "aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890" } { valid := false } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  raw : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => m.raw.length = i.raw.length ∧
                     m.raw.toList.all Char.isAlphanum = true

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.raw.length = 50
  post := fun m o => o.valid = true ∧
                     m.raw.toList.all Char.isAlphanum = true

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  simp only at h
  exact h.1

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, fun i o _ ⟨m, ⟨hp, hq⟩, ho⟩ => ?_⟩
  simp only at hp hq ho
  rw [ho, hp, hq]