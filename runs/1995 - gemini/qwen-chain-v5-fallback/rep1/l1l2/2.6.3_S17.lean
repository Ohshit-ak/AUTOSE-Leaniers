import ContractForge
open ContractForge

-- 2.6.3/S17: However it must be recognized that:

-- L0 spec

structure Input where
  visitorId : String
  deriving DecidableEq, Repr

structure Output where
  recognized : Bool
  message    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.visitorId ≠ ""
  post := fun i o => (o.recognized = true ↔ i.visitorId = "1234567890") ∧
                     (o.recognized = false → o.message = "Visitor not recognized")

example : Spec.pre { visitorId := "1234567890" } ∧
          Spec.post { visitorId := "1234567890" }
                    { recognized := true, message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { recognized := decide (x.visitorId = "1234567890"),
    message := if x.visitorId = "1234567890" then "" else "Visitor not recognized" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
