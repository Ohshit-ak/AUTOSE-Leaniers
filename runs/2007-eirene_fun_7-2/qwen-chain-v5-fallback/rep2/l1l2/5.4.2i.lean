import ContractForge
open ContractForge

-- 5.4.2i: 5.4.2i The design of the equipment shall make it possible to install it within a cab complying with the requirements of UIC fiche 651 concerning the layout of cab equipment . (M)

-- L0 spec

structure Input where
  cabLayout : String
  deriving DecidableEq, Repr

structure Output where
  installed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabLayout ≠ ""
  post := fun i o => o.installed = true ↔
    i.cabLayout = "UIC fiche 651 concerning the layout of cab equipment"

example : Spec.pre { cabLayout := "UIC fiche 651 concerning the layout of cab equipment" } ∧
          Spec.post { cabLayout := "UIC fiche 651 concerning the layout of cab equipment" }
                    { installed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { installed := decide (x.cabLayout = "UIC fiche 651 concerning the layout of cab equipment") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
