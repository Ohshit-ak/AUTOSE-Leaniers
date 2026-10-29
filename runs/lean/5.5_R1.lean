-- 5.5/R1: The system shall perform searches via Dijkstra's shortest path algorithm.
-- checked: None

structure Graph (V : Type) where
  vertices : List V
  edges    : List (V × V × Nat)

structure SearchResult (V : Type) where
  path : List V
  cost : Nat

structure Contract (V : Type) where
  pre  : Graph V → Prop
  post : Graph V → SearchResult V → Prop

def Spec : Contract V where
  pre g := g.vertices ≠ [] ∧ g.edges ≠ []
  post g sr := sr.path ≠ [] ∧ sr.cost = (g.vertices, g.vertices, 0).dijkstraCost

example : ∃ g sr, Spec.pre g ∧ Spec.post g sr :=
begin
  -- Define a simple graph with two vertices and an edge
  let g := Graph.{V := Nat} ⟨[0, 1], [(0, 1, 1)]⟩,
  -- Define the search result with the path and cost
  let sr := SearchResult.{V := Nat} ⟨[0, 1], 1⟩,
  -- Check the pre and post conditions
  split,
  { exact Spec.pre g },
  { exact Spec.post g sr }
end
