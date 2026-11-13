import ContractForge
open ContractForge

-- 3.2.1.4.3/S2: The selected block can' mt ove near other blocks at least 0.05x from the others blocks.
-- compiles: True · rejects_bad_example: True · checked: True

structure Block where
  position : Nat  -- position on a linear axis, e.g., 0, 1, 2, ...
  size     : Nat  -- size of the block, e.g., 1, 2, ...
  deriving DecidableEq, Repr

structure Input where
  selectedBlock : Block
  otherBlocks   : List Block
  distance      : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  newPositions : List Block
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.distance ≥ 5
  post := fun i o => (o.accepted = true ↔
    ∀ b ∈ i.otherBlocks, i.selectedBlock.position + i.selectedBlock.size ≤ b.position - i.distance ∨
                          b.position + b.size ≤ i.selectedBlock.position - i.distance) ∧
    (o.accepted = false ↔
    ∃ b ∈ i.otherBlocks, i.selectedBlock.position + i.selectedBlock.size ≥ b.position - i.distance ∧
                         b.position + b.size ≥ i.selectedBlock.position - i.distance) ∧
    o.newPositions.length = i.otherBlocks.length ∧
    ∀ b ∈ i.otherBlocks, o.newPositions.contains b

example : Spec.pre { selectedBlock := { position := 10, size := 2 }, otherBlocks := [{ position := 20, size := 3 }], distance := 5 } ∧ Spec.post { selectedBlock := { position := 10, size := 2 }, otherBlocks := [{ position := 20, size := 3 }], distance := 5 } { accepted := true, newPositions := [{ position := 20, size := 3 }] } := by
  unfold Spec; decide
