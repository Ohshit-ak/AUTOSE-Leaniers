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

structure Mid where
  raw : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => m.raw.length ≥ 4 ∧ m.raw.length ≤ 10 ∧
    m.raw.toList.all Char.isAlphanum = true

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.raw.length ≥ 4 ∧ m.raw.length ≤ 10 ∧
    m.raw.toList.all Char.isAlphanum = true
  post := fun m o => o.valid = true

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  exact h.2

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]