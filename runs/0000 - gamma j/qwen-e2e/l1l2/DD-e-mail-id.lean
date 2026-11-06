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

-- Decompose the spec into two components

def RawLengthContract : Contract Input (Output × Bool) where
  pre  := fun i => i.raw.length = 50
  post := fun i (o, _) => o = (i.raw.length = 50)

def AlphanumContract : Contract (Output × Bool) Output where
  pre  := fun (o, _) => o.1
  post := fun (o, _) o' => o'.valid = true ↔ o.1 ∧ o.1.toList.all Char.isAlphanum = true

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem RawLengthCompatible : Contract.Compatible RawLengthContract AlphanumContract :=
  by
    discharge_po

-- Prove PO2: the composition refines the spec

theorem SpecRefines : Contract.Refines (RawLengthContract.seq AlphanumContract) Spec :=
  by
    unfold RawLengthContract AlphanumContract Spec
    discharge_po