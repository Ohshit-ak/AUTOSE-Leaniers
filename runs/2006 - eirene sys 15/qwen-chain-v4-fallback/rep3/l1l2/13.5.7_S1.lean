import ContractForge
open ContractForge

-- 13.5.7/S1: Confirmation messages shall be sent to a confirmation centre using a defined short code (see table 9-10), which shall be associated with the GSM network.

-- L0 spec

structure Input where
  shortCode : String
  network   : String
  deriving DecidableEq, Repr

structure Output where
  confirmationSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shortCode.length = 4 ∧
                  i.shortCode.toList.all Char.isDigit = true ∧
                  i.network ≠ ""
  post := fun i o => o.confirmationSent = true ↔
                     (i.shortCode = "1122" ∧ i.network = "GSM")

example : Spec.pre { shortCode := "1122", network := "GSM" } ∧
          Spec.post { shortCode := "1122", network := "GSM" }
                    { confirmationSent := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { confirmationSent := decide (x.shortCode = "1122" ∧ x.network = "GSM") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
