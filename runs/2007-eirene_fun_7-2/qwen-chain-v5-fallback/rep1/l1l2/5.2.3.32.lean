import ContractForge
open ContractForge

-- 5.2.3.32: 5.2.3.32 Where a change of train number is required during the course of a trains journey, it shall be possible for the driver to initiate the change or override the automatic change. This shall be carried out by entering the train number (option 1 in 5.2.3.26). (M)

-- L0 spec

structure Input where
  currentTrainNumber : String
  newTrainNumber     : String
  deriving DecidableEq, Repr

structure Output where
  currentTrainNumber : String
  newTrainNumber     : String
  accepted           : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentTrainNumber ≠ "" ∧ i.newTrainNumber ≠ ""
  post := fun i o => (o.accepted = true ↔
    (i.currentTrainNumber ≠ i.newTrainNumber) ∧
    (o.currentTrainNumber = i.currentTrainNumber ∧ o.newTrainNumber = i.newTrainNumber)) ∧
    (o.accepted = false ↔
    (i.currentTrainNumber = i.newTrainNumber) ∧
    (o.currentTrainNumber = i.currentTrainNumber ∧ o.newTrainNumber = i.newTrainNumber))

example : Spec.pre { currentTrainNumber := "1234", newTrainNumber := "5678" } ∧
          Spec.post { currentTrainNumber := "1234", newTrainNumber := "5678" }
                    { currentTrainNumber := "1234", newTrainNumber := "5678", accepted := true } := by
  unfold Spec; decide

example : Spec.pre { currentTrainNumber := "1234", newTrainNumber := "1234" } ∧
          Spec.post { currentTrainNumber := "1234", newTrainNumber := "1234" }
                    { currentTrainNumber := "1234", newTrainNumber := "1234", accepted := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { currentTrainNumber := x.currentTrainNumber, newTrainNumber := x.newTrainNumber,
    accepted := decide ((x.currentTrainNumber ≠ x.newTrainNumber) ∧
                        (x.currentTrainNumber = x.currentTrainNumber ∧ x.newTrainNumber = x.newTrainNumber)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
