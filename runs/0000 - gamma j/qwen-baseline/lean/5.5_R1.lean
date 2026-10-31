-- 5.5/R1: The system shall perform searches via Dijkstra's shortest path algorithm.
-- checked: False

structure Input where
  graph : List (Nat × Nat × Nat)
  start : Nat
  end : Nat

structure Output where
  path : List Nat
  distance : Nat

def Spec : Contract Input Output where
  pre  := fun i => 
    i.graph.forall (fun (u, v, w) => w ≥ 0) ∧
    i.start ∈ i.graph.map (·.1) ∧
    i.end ∈ i.graph.map (·.1)
  post := fun i o => 
    o.path.forall (fun n => n ∈ i.graph.map (·.1)) ∧
    o.path.length ≥ 1 ∧
    o.path.head = i.start ∧
    o.path.last = i.end ∧
    o.distance = i.graph.foldr (fun (u, v, w) acc => 
      if o.path.contains u ∧ o.path.contains v then min acc (w + o.distance) else acc) 0

example : Spec.pre ⟨[ (1, 2, 3), (2, 3, 4) ], 1, 3 ⟩ ∧ Spec.post ⟨[ 1, 2, 3 ], 6 ⟩ := by
  simp [Spec]
