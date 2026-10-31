import ContractForge
open ContractForge

-- 5.5/R1: The system shall perform searches via Dijkstra's shortest path algorithm.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  startNode : Nat
  endNode   : Nat
  graph     : List (Nat × Nat × Nat)
  deriving DecidableEq, Repr

structure Output where
  path : List Nat
  cost : Nat
  deriving DecidableEq, Repr

-- IMPL: Dijkstra

def Spec : Contract Input Output where
  pre  := fun i => i.startNode < i.endNode ∧ i.graph.Nodup
  post := fun i o => (o.path = [] ↔ i.startNode = i.endNode) ∧
                     (o.path ≠ [] → o.path.contains i.startNode ∧
                      o.path.contains i.endNode ∧
                      o.cost = o.path.sum (·.3))

example : Spec.pre { startNode := 1, endNode := 4, graph := [(1, 2, 5), (2, 3, 2), (3, 4, 3)] } ∧
          Spec.post { startNode := 1, endNode := 4, graph := [(1, 2, 5), (2, 3, 2), (3, 4, 3)] }
                    { path := [1, 2, 3, 4], cost := 10 } := by
  unfold Spec; decide
