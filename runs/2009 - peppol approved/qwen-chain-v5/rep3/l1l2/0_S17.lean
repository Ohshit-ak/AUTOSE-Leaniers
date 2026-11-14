import ContractForge
open ContractForge

-- 0/S17: In reference to this, D2.2 will comprise a short overview of the updated state of practice and the relation to current more detailed results of WP2.

-- L0 spec

structure Input where
  overview : String
  relation : String
  deriving DecidableEq, Repr

structure Output where
  overview : String
  relation : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.overview ≠ "" ∧
                     o.relation ≠ "" ∧
                     (o.overview = "Short overview of the updated state of practice." ∨ o.overview = i.overview) ∧
                     (o.relation = "Relation to current more detailed results of WP2." ∨ o.relation = i.relation)

example : Spec.pre { overview := "x", relation := "y" } ∧
          Spec.post { overview := "x", relation := "y" }
                    { overview := "Short overview of the updated state of practice.", relation := "Relation to current more detailed results of WP2." } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { overview := x.overview, relation := x.relation }
