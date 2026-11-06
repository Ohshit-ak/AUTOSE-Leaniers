import ContractForge
open ContractForge

-- DD-quantity: the number of units of each selected item that the customer is ordering; default = 1; maximum = quantity presently in inventory

-- L0 spec

structure Input where
  value : Nat
  max_ref : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ 1 ≤ i.value ∧ i.value ≤ i.max_ref

example : Spec.pre { value := 5, max_ref := 10 } ∧
          Spec.post { value := 5, max_ref := 10 } { valid := true } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  value : Nat
  max_ref : Nat
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => m.value = i.value ∧ m.max_ref = i.max_ref

def ComputeContract : Contract Mid Output where
  pre  := fun m => 1 ≤ m.value ∧ m.value ≤ m.max_ref
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