import ContractForge
open ContractForge

-- 5.1/R5: The system shall be able to search for a specified product in less than 1 second.

-- L0 spec

structure Input where
  product : String
  items   : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product ≠ ""
  post := fun i o => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                     (o.results.length > 0 → o.elapsedMicros < 1000000)

example : Spec.pre { product := "laptop", items := ["laptop", "phone", "tablet"] } ∧
          Spec.post { product := "laptop", items := ["laptop", "phone", "tablet"] }
                    { results := ["laptop"], elapsedMicros := 500000 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  product : String
  items   : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product ≠ ""
  post := fun i o => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                     (o.results.length > 0 → o.elapsedMicros < 1000000)

-- Decompose the spec into two components

def ParseContract : Contract Input (Output × Nat) where
  pre  := fun i => i.product ≠ ""
  post := fun i (o, _) => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                          (o.results.length > 0 → o.elapsedMicros < 1000000)

def ComputeContract : Contract (Output × Nat) Output where
  pre  := fun (o, _) => true
  post := fun (o, _), o' => o'.results.length = o.results.length ∧
                             o'.elapsedMicros = o.elapsedMicros

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1_Parse : Contract.Compatible ParseContract Spec :=
  by
    intros i o
    simp [ParseContract, Spec]
    split
    -- First condition
    simp [ParseContract, Spec]
    exact dec_trivial
    -- Second condition
    simp [ParseContract, Spec]
    exact dec_trivial

theorem PO1_Compute : Contract.Compatible ComputeContract ParseContract :=
  by
    intros (o, elapsed) o'
    simp [ComputeContract, ParseContract]
    split
    -- First condition
    simp [ComputeContract, ParseContract]
    exact dec_trivial
    -- Second condition
    simp [ComputeContract, ParseContract]
    exact dec_trivial

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (ParseContract.seq ComputeContract) Spec :=
  by
    intros i o
    simp [ParseContract, ComputeContract, Spec]
    split
    -- First condition
    simp [ParseContract, ComputeContract, Spec]
    exact dec_trivial
    -- Second condition
    simp [ParseContract, ComputeContract, Spec]
    exact dec_trivial