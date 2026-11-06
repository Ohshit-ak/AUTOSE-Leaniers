import ContractForge
open ContractForge

-- 5.5/R5: The system shall validate email address existence.

-- L0 spec

structure Input where
  email : String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ ""
  post := fun i o => o.exists_ = true ↔ i.email.toList.all Char.isAlphanum = true ∧
                     i.email.contains '@' ∧ i.email.contains '.' ∧
                     i.email.length ≥ 6

example : Spec.pre { email := "test@example.com" } ∧ Spec.post { email := "test@example.com" } { exists_ := false } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  email : String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ ""
  post := fun i o => o.exists_ = true ↔ i.email.toList.all Char.isAlphanum = true ∧
                     i.email.contains '@' ∧ i.email.contains '.' ∧
                     i.email.length ≥ 6

-- Decompose the spec into two components

def EmailValidContract : Contract Input Bool where
  pre  := fun i => i.email ≠ ""
  post := fun i v => v = true ↔ i.email.toList.all Char.isAlphanum = true ∧
                     i.email.contains '@' ∧ i.email.contains '.' ∧
                     i.email.length ≥ 6

def ExistsContract : Contract Bool Output where
  pre  := fun b => b
  post := fun b o => o.exists_ = true ↔ b

-- Prove PO1: EmailValidContract's assumption follows from Spec's guarantee
example : Contract.Compatible (Spec.post) (EmailValidContract.pre) := by
  unfold Spec EmailValidContract; simp; discharge_po

-- Prove PO2: the composition refines the spec
example : Contract.Refines (Spec.pre.seq EmailValidContract.post).seq ExistsContract.post Spec.post := by
  unfold Spec EmailValidContract ExistsContract; simp; discharge_po