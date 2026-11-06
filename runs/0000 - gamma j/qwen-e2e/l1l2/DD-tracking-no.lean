import ContractForge
open ContractForge

-- DD-tracking-no: Number to track the order; 20 characters alphanumeric

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
    (i.raw.length = 20 ∧
     i.raw.toList.all Char.isAlphanum = true)

example : Spec.pre { raw := "A1B2C3D4E5F6G7H8I9J0" } ∧
          Spec.post { raw := "A1B2C3D4E5F6G7H8I9J0" }
                    { valid := true } := by
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
    (i.raw.length = 20 ∧
     i.raw.toList.all Char.isAlphanum = true)

-- Decompose the spec into two components

def LengthCheckContract : Contract Input Input where
  pre  := fun i => i.raw.length = 20
  post := fun i i' => i' = { raw := i.raw }

def AlphanumericCheckContract : Contract Input Output where
  pre  := fun i => i.raw.toList.all Char.isAlphanum
  post := fun i o => o.valid = true

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem LengthCheckCompatible : Contract.Compatible (LengthCheckContract) Spec :=
  by
    unfold LengthCheckContract Spec
    intros i i' h
    simp [h]
    discharge_po

theorem AlphanumericCheckCompatible : Contract.Compatible (AlphanumericCheckContract) (LengthCheckContract) :=
  by
    unfold AlphanumericCheckContract LengthCheckContract
    intros i i' h
    simp [h]
    discharge_po

-- Prove PO2: the composition refines the spec

def LengthCheckAlphanumericCheck : Contract Input Output :=
  (LengthCheckContract).seq (AlphanumericCheckContract)

theorem LengthCheckAlphanumericCheckRefinesSpec : Contract.Refines (LengthCheckAlphanumericCheck) Spec :=
  by
    unfold LengthCheckAlphanumericCheck Spec
    intros i o h
    simp [h]
    discharge_po

-- The complete file with the contracts and proofs

structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 20 ∧
     i.raw.toList.all Char.isAlphanum = true)

def LengthCheckContract : Contract Input Input where
  pre  := fun i => i.raw.length = 20
  post := fun i i' => i' = { raw := i.raw }

def AlphanumericCheckContract : Contract Input Output where
  pre  := fun i => i.raw.toList.all Char.isAlphanum
  post := fun i o => o.valid = true

theorem LengthCheckCompatible : Contract.Compatible (LengthCheckContract) Spec :=
  by
    unfold LengthCheckContract Spec
    intros i i' h
    simp [h]
    discharge_po

theorem AlphanumericCheckCompatible : Contract.Compatible (AlphanumericCheckContract) (LengthCheckContract) :=
  by
    unfold AlphanumericCheckContract LengthCheckContract
    intros i i' h
    simp [h]
    discharge_po

def LengthCheckAlphanumericCheck : Contract Input Output :=
  (LengthCheckContract).seq (AlphanumericCheckContract)

theorem LengthCheckAlphanumericCheckRefinesSpec : Contract.Refines (LengthCheckAlphanumericCheck) Spec :=
  by
    unfold LengthCheckAlphanumericCheck Spec
    intros i o h
    simp [h]
    discharge_po