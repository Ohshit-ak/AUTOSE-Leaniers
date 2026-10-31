import ContractForge
open ContractForge

-- 5.5/R1: The system shall perform searches via Dijkstra's shortest path algorithm.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  start : Nat
  end_   : Nat
  edges : List (Nat × Nat × Nat)
  deriving DecidableEq, Repr

structure Output where
  path : List Nat
  cost : Nat
  deriving DecidableEq, Repr

-- IMPL: Dijkstra's shortest path algorithm

def Spec : Contract Input Output where
  pre  := fun i => i.start ≠ i.end_ ∧ i.edges.Nodup ∧
                  ∀ (u v w : Nat) ∈ i.edges, u ≠ v ∧ w ≥ 0
  post := fun i o => o.path.Nodup ∧ o.path.first = i.start ∧ o.path.last = i.end_ ∧
                     o.cost = o.path.sum (·.2) ∧
                     o.path.Pairwise (· ≤ ·) ∧
                     (∃ (p : List Nat) ∈ o.path, p.length = o.path.length)

example : Spec.pre { start := 0, end_ := 3, edges := [(0, 1, 1), (1, 2, 2), (2, 3, 3)] } ∧
          Spec.post { start := 0, end_ := 3, edges := [(0, 1, 1), (1, 2, 2), (2, 3, 3)] }
                    { path := [0, 1, 2, 3], cost := 6 } := by
  unfold Spec; decide
