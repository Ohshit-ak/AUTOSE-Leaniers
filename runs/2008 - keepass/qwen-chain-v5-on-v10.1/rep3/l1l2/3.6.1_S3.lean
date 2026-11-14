import ContractForge
open ContractForge

-- 3.6.1/S3: When creating a group/subgroup the user must select a name and then he can add entries into it.

-- L0 spec

structure Group where
  name   : String
  entries : List String
  deriving DecidableEq, Repr

structure Input where
  name   : String
  entries : List String
  deriving DecidableEq, Repr

structure Output where
  name   : String
  entries : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ ""
  post := fun i o => o.name = i.name ∧ o.entries = i.entries

example : Spec.pre { name := "New Group", entries := ["Entry1", "Entry2"] } ∧
          Spec.post { name := "New Group", entries := ["Entry1", "Entry2"] }
                    { name := "New Group", entries := ["Entry1", "Entry2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { name := x.name,
    entries := x.entries }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
