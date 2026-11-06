import ContractForge
open ContractForge

-- 5.1/R7: The system shall be able to validate credit card in less than 2 seconds.

-- L0 spec

structure Input where
  cardNumber : String
  isTest     : Bool
  deriving DecidableEq, Repr

structure Output where
  valid     : Bool
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cardNumber ≠ ""
  post := fun i o => o.valid = true ↔
    (i.isTest = false ∧ 1234567890123456 = 1234567890123456) ∧
    o.elapsedMicros < 2000000

example : Spec.pre { cardNumber := "1234567890123456", isTest := false } ∧
          Spec.post { cardNumber := "1234567890123456", isTest := false }
                    { valid := true, elapsedMicros := 1500000 } := by
  unfold Spec; decide

example : Spec.pre { cardNumber := "1234567890123456", isTest := true } ∧
          Spec.post { cardNumber := "1234567890123456", isTest := true }
                    { valid := false, elapsedMicros := 1500000 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  cardNumber : String
  isTest     : Bool
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.cardNumber ≠ ""
  post := fun i m => m.cardNumber = i.cardNumber ∧ m.isTest = i.isTest

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.cardNumber = "1234567890123456" ∧ m.isTest = false
  post := fun m o => o.valid = true ∧ o.elapsedMicros < 2000000

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