-- 5.5/R1: The system shall perform searches via Dijkstra's shortest path algorithm.
-- checked: False

structure Input where
  startNode : Nat
  endNode   : Nat
  graph     : List (Nat × Nat × Nat)
  deriving DecidableEq, Repr

structure Output where
  path     : List Nat
  cost     : Nat
  deriving DecidableEq, Repr

-- IMPL: Dijkstra's shortest path algorithm

def Spec : Contract Input Output where
  pre  := fun i => i.startNode ≠ i.endNode ∧ i.graph.Nodup
  post := fun i o => o.path.length = o.path.count i.endNode + 1 ∧
                     o.path.all (fun n => n ∈ i.graph.map (·.1)) ∧
                     o.path.any (fun n => n = i.startNode) ∧
                     o.path.any (fun n => n = i.endNode) ∧
                     o.cost = o.path.sum (·.3) ∧
                     o.path.init.all (fun n m => (n, m, _) ∈ i.graph)

example : Spec.pre { startNode := 0, endNode := 3, graph := [(0, 1, 2), (0, 2, 4), (1, 2, 1), (1, 3, 3), (2, 3, 1)] } ∧
          Spec.post { startNode := 0, endNode := 3, graph := [(0, 1, 2), (0, 2, 4), (1, 2, 1), (1, 3, 3), (2, 3, 1)] }
                    { path := [0, 1, 3], cost := 5 } := by
  unfold Spec; decide
