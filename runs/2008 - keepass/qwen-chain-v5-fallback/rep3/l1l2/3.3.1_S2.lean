import ContractForge
open ContractForge

-- 3.3.1/S2: But when it is time for the database to close or during his working on the database, he can save the changes made.

-- L0 spec

structure Input where
  changes : List String
  saving  : Bool
  deriving DecidableEq, Repr

structure Output where
  saved   : Bool
  changes : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.saving
  post := fun i o => (o.saved = true ↔ i.saving) ∧
                     (o.changes = i.changes)

example : Spec.pre { changes := ["change1", "change2"], saving := true } ∧
          Spec.post { changes := ["change1", "change2"], saving := true }
                    { saved := true, changes := ["change1", "change2"] } := by
  unfold Spec; decide

-- IMPL: Save changes when saving is true
def saveDatabase (i : Input) : Output :=
  { saved := i.saving, changes := i.changes }

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { saved := decide (x.saving),
    changes := x.changes }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
