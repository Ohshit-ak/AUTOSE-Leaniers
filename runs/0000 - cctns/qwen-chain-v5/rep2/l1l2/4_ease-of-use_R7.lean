import ContractForge
open ContractForge

-- 4/ease-of-use/R7: The System must allow persistent defaults for data entry where desirable. These defaults should include: user-definable values; values same as previous item; values derived from context, e.g. date, file reference, user identifier;

-- L0 spec

structure Input where
  defaults : List String
  deriving DecidableEq, Repr

structure Output where
  entries : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.defaults ≠ []
  post := fun i o => o.entries.length = i.defaults.length ∧
                     (o.entries.zip i.defaults).all (fun p => p.2 = p.1 ∨ p.2 = "previous" ∨
                     (p.2 = "context" ∧ p.1 = "date" ∨ p.1 = "file" ∨ p.1 = "user"))

example : Spec.pre { defaults := ["date", "file", "user"] } ∧
          Spec.post { defaults := ["date", "file", "user"] }
                    { entries := ["date", "file", "user"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { entries := x.defaults }
