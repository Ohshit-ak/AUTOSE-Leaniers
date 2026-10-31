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

-- IMPL: Dijkstra

def Spec : Contract Input Output where
  pre  := fun i => i.start ≠ i.end_ ∧ i.edges.Nodup ∧
                  ∀ x ∈ i.edges, 0 ≤ x.2
  post := fun i o => o.path.length = o.path.count i.end_ + 1 ∧
                     o.path.all (fun n => 0 ≤ n ∧ n ≤ i.end_) ∧
                     o.path.sum (fun n => i.edges.find? (fun e => e.1 = n ∧ e.2 = o.path.nth (n - 1)) |>.get!.3) = o.cost ∧
                     (o.path.nth 0 = i.start ∧ o.path.nth (o.path.length - 1) = i.end_ ↔
                      o.path = Dijkstra i.start i.end_ i.edges)

example : Spec.pre { start := 1, end_ := 5, edges := [(1, 2, 1), (2, 3, 2), (3, 4, 3), (4, 5, 4)] } ∧
          Spec.post { start := 1, end_ := 5, edges := [(1, 2, 1), (2, 3, 2), (3, 4, 3), (4, 5, 4)] }
                    { path := [1, 2, 3, 4, 5], cost := 10 } := by
  unfold Spec; decide
