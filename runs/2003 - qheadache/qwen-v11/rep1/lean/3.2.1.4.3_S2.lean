import ContractForge
open ContractForge

-- 3.2.1.4.3/S2: The selected block can' mt ove near other blocks at least 0.05x from the others blocks.
-- compiles: True · rejects_bad_example: True · checked: True

structure Block where
  position : Nat
  deriving DecidableEq, Repr

structure Input where
  selectedBlock : Block
  otherBlocks   : List Block
  distance      : Nat
  deriving DecidableEq, Repr

structure Output where
  selectedBlock : Block
  otherBlocks   : List Block
  accepted      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.distance ≥ 5
  post := fun i o => (o.accepted = true ↔
    ∀ other ∈ i.otherBlocks, i.selectedBlock.position + 5 ≤ other.position - 1 ∨
    other.position + 5 ≤ i.selectedBlock.position - 1) ∧
    (o.accepted = false ↔
    ∃ other ∈ i.otherBlocks, i.selectedBlock.position + 5 ≥ other.position ∨
    other.position + 5 ≥ i.selectedBlock.position)

example : Spec.pre { selectedBlock := { position := 10 }, otherBlocks := [], distance := 10 } ∧ Spec.post { selectedBlock := { position := 10 }, otherBlocks := [], distance := 10 } { selectedBlock := { position := 10 }, otherBlocks := [{ position := 16 }], accepted := true } := by
  unfold Spec; decide
