import ContractForge
open ContractForge

-- 4/ease-of-use/R7: The System must allow persistent defaults for data entry where desirable. These defaults should include: user-definable values; values same as previous item; values derived from context, e.g. date, file reference, user identifier;

-- L0 spec

structure Input where
  defaults : List String
  deriving DecidableEq, Repr

structure Output where
  defaults : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.defaults ≠ []
  post := fun i o => o.defaults = i.defaults

example : Spec.pre { defaults := ["user123", "2023-10-01", "file.txt"] } ∧
          Spec.post { defaults := ["user123", "2023-10-01", "file.txt"] }
                    { defaults := ["user123", "2023-10-01", "file.txt"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { defaults := x.defaults }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
