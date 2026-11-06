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

structure Mid where
  raw : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => m.raw.length = i.raw.length ∧
    (4 ≤ m.raw.length ∧ m.raw.length ≤ 10 ∧
     m.raw.toList.all (·.isAlphanum) = true)

def ComputeContract : Contract Mid Output where
  pre  := fun m => 4 ≤ m.raw.length ∧ m.raw.length ≤ 10 ∧
    m.raw.toList.all (·.isAlphanum) = true
  post := fun m o => o.valid = true

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  simp only at h
  exact h.1

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq⟩, ho⟩
  simp only at hp hq ho
  rw [ho, hp, hq]