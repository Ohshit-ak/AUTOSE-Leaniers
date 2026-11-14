import ContractForge
open ContractForge

-- 2.5.10/S1: Systems supporting OM must be able to create and send messages for countermeasure administration requests.

-- L0 spec

structure Input where
  countermeasure : String
  patientID      : String
  dose           : Nat
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  messageID : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.countermeasure ≠ "" ∧ i.patientID ≠ "" ∧ 0 < i.dose
  post := fun i o => (o.sent = true ↔
    i.countermeasure = "vaccine" ∧ i.patientID.toList.all (fun c => c.isAlpha || c.isDigit) = true ∧ 0 < i.dose)

example : Spec.pre { countermeasure := "vaccine", patientID := "P12345", dose := 2 } ∧
          Spec.post { countermeasure := "vaccine", patientID := "P12345", dose := 2 }
                    { sent := true, messageID := "MSG12345" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sent := decide (x.countermeasure = "vaccine" ∧ x.patientID.toList.all (fun c => c.isAlpha || c.isDigit) = true ∧ 0 < x.dose),
    messageID := "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
