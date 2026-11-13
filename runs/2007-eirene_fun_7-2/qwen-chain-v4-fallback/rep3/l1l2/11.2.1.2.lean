import ContractForge
open ContractForge

-- 11.2.1.2: 11.2.1.2 The primary usage of functional addressing will be for controllers to establish communications with train drivers by making use of the train number. The train number will vary between journeys although EIRENE equipment in the cab is unlikely to change. (I)

-- L0 spec

structure Input where
  trainNumber : String
  deriving DecidableEq, Repr

structure Output where
  communicationEstablished : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ ""
  post := fun i o => o.communicationEstablished = true ↔
    (i.trainNumber.toList.all Char.isDigit = true) ∧
    (i.trainNumber.length = 4) ∧
    (o.communicationEstablished = false →
      (i.trainNumber = "1234" ∨ i.trainNumber = "5678"))

example : Spec.pre { trainNumber := "1234" } ∧
          Spec.post { trainNumber := "1234" }
                    { communicationEstablished := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { communicationEstablished := decide (x.trainNumber.toList.all Char.isDigit ∧ x.trainNumber.length = 4 ∧ (x.trainNumber = "1234" ∨ x.trainNumber = "5678")) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
