import ContractForge
open ContractForge

-- 5.2.3.32: 5.2.3.32 Where a change of train number is required during the course of a trains journey, it shall be possible for the driver to initiate the change or override the automatic change. This shall be carried out by entering the train number (option 1 in 5.2.3.26). (M)

-- L0 spec

structure Input where
  trainNumber : String
  override    : Bool
  deriving DecidableEq, Repr

structure Output where
  trainNumber : String
  accepted    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ "" ∧ (i.override ∨ i.trainNumber.toList.all Char.isDigit = true)
  post := fun i o => (o.accepted = true ↔ i.override) ∧
                     (o.trainNumber = if i.override then i.trainNumber else o.trainNumber)

example : Spec.pre { trainNumber := "12345", override := true } ∧
          Spec.post { trainNumber := "12345", override := true }
                    { accepted := true, trainNumber := "12345" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { trainNumber := if x.override then x.trainNumber else "default",
    accepted := decide (x.override) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
