import ContractForge
open ContractForge

-- 7.5.9/S1: Changing the battery shall not result in the loss of data stored in the radio.

-- L0 spec

structure Battery where
  id : Nat
  deriving DecidableEq, Repr

structure Radio where
  data : String
  battery : Option Battery
  deriving DecidableEq, Repr

structure Input where
  oldBattery : Option Battery
  newBattery : Option Battery
  radioData  : String
  deriving DecidableEq, Repr

structure Output where
  radioData : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.oldBattery ≠ none ∧ i.newBattery ≠ none
  post := fun i o => o.radioData = i.radioData

example : Spec.pre { oldBattery := some { id := 1 }, newBattery := some { id := 2 },
                     radioData := "config" } ∧
          Spec.post { oldBattery := some { id := 1 }, newBattery := some { id := 2 },
                      radioData := "config" }
                    { radioData := "config" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { radioData := x.radioData }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
