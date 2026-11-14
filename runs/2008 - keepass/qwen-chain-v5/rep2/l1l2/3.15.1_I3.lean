import ContractForge
open ContractForge

-- 3.15.1/I3: The third method is to use the system-wide auto-type hot key so that KeePass can search all entries in the database for matching sequences.

-- L0 spec

structure Input where
  database : List String
  query    : String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o => 
    (∀ r ∈ o.results, r ∈ i.database ∧ r.toList.any (fun c => i.query.contains c)) ∧
    o.results.length ≤ i.database.length ∧
    (∀ r ∈ i.database, r.toList.any (fun c => i.query.contains c) → r ∈ o.results) ∧
    (o.results = [] ↔ i.database.all (fun r => ¬(r.toList.any (fun c => i.query.contains c))))

example : Spec.pre { database := [], query := "exa" } ∧ Spec.post { database := [], query := "exa" } { results := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := 
      (x.database.filter (fun r => r.toList.any (fun c => x.query.contains c)))
      .take (x.database.length - (x.database.filter (fun r => ¬r.toList.any (fun c => x.query.contains c))).length)
      .take (x.database.length - (x.database.filter (fun r => ¬r.toList.any (fun c => x.query.contains c))).length)
  }
