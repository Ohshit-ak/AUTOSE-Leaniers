-- 5.5/R1: The system shall perform searches via Dijkstra's shortest path algorithm.
-- checked: False

structure Input where
  graph : List (Nat × Nat × Nat)
  start : Nat
  deriving DecidableEq, Repr

structure Output where
  path : List Nat
  distance : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.graph.Nodup ∧ i.start ∈ i.graph.map (·.1)
  post := fun i o => o.path.length > 0 ∧
                     o.distance = o.path.sum (fun n => i.graph.find? (n, o.path.head).get_or 0 .3rd) ∧
                     o.path.all (fun n => i.graph.contains (n, o.path.nth? (o.path.indexOf n + 1).get 0, 0)) ∧
                     o.path.head = i.start ∧
                     o.path.last = i.graph.find? (i.start, o.path).get_or i.start 0.2nd

example : Spec.pre { graph := [(1, 2, 5), (1, 3, 10), (2, 3, 2)], start := 1 } ∧
          Spec.post { graph := [(1, 2, 5), (1, 3, 10), (2, 3, 2)], start := 1 }
                     { path := [1, 2, 3], distance := 7 } := by
  unfold Spec; decide
