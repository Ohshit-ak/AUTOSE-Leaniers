import ContractForge
open ContractForge

-- 2.14.3/I4: Gemini software developers should maintain accurate change logs showing software modifications as they are applied to the system software.

-- L0 spec

structure ChangeLogEntry where
  timestamp : Nat
  author    : String
  description : String
  deriving DecidableEq, Repr

structure Input where
  changes : List ChangeLogEntry
  deriving DecidableEq, Repr

structure Output where
  changes : List ChangeLogEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.changes.Nodup
  post := fun i o => o.changes = i.changes

example : Spec.pre { changes := [{ timestamp := 1, author := "Alice", description := "Initial setup" },
                                  { timestamp := 2, author := "Bob", description := "Feature addition" }] } ∧
          Spec.post { changes := [{ timestamp := 1, author := "Alice", description := "Initial setup" },
                                   { timestamp := 2, author := "Bob", description := "Feature addition" }] }
                    { changes := [{ timestamp := 1, author := "Alice", description := "Initial setup" },
                                  { timestamp := 2, author := "Bob", description := "Feature addition" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { changes := x.changes }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
