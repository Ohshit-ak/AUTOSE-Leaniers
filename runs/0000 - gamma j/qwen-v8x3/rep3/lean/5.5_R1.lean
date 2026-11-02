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
                  (∀ (u v c) ∈ i.edges, 0 ≤ u ∧ 0 ≤ v ∧ 0 ≤ c)
  post := fun i o => o.path.Nodup ∧ o.path.length > 0 ∧
                     o.path.first = i.start ∧ o.path.last = i.end_ ∧
                     o.cost = o.path.sum (fun u => 0) ∧
                     (∀ u ∈ o.path, ∃ v ∈ o.path, (u, v, _) ∈ i.edges) ∧
                     (∀ (u v c) ∈ i.edges, (u, v, c) ∈ o.path.pairwise (·, ·, _))

example : Spec.pre { start := 1, end_ := 5, edges := [(1, 2, 2), (2, 3, 3), (3, 4, 1), (4, 5, 4)] } ∧
          Spec.post { start := 1, end_ := 5, edges := [(1, 2, 2), (2, 3, 3), (3, 4, 1), (4, 5, 4)] }
                    { path := [1, 2, 3, 4, 5], cost := 10 } := by
  unfold Spec; decide
