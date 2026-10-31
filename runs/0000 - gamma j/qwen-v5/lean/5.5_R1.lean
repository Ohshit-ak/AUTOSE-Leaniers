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
  pre  := fun i => i.startNode < i.graph.length ∧ i.endNode < i.graph.length
  post := fun i o => o.path.length > 0 ∧
                     o.path.all (fun n => n < i.graph.length) ∧
                     o.path.head = i.startNode ∧
                     o.path.last = i.endNode ∧
                     i.graph.Perm (o.path.map (fun n => (n.1, n.2, n.3)))

example : Spec.pre { startNode := 0, endNode := 4, graph := [(0, 1, 4), (0, 2, 1), (1, 2, 2), (1, 3, 2), (1, 4, 5), (2, 3, 3), (3, 4, 1)] } ∧
          Spec.post { startNode := 0, endNode := 4, graph := [(0, 1, 4), (0, 2, 1), (1, 2, 2), (1, 3, 2), (1, 4, 5), (2, 3, 3), (3, 4, 1)] }
                    { path := [0, 2, 3, 4], cost := 4 } := by
  unfold Spec; decide
