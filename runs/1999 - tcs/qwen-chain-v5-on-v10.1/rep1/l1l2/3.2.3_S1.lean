import ContractForge
open ContractForge

-- 3.2.3/S1: The TCS will have the functionality necessary to manage all aspects of payload product handling to include receiving, processing, displaying, and performing limited exploitation.

-- L0 spec

structure Input where
  payloadId : String
  operation : String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.payloadId ≠ "" ∧ (i.operation = "receive" ∨ i.operation = "process" ∨ i.operation = "display" ∨ i.operation = "exploit")
  post := fun i o => o.success = true ↔
    (i.operation = "receive" → o.message = "Payload received successfully")
    ∧ (i.operation = "process" → o.message = "Payload processing initiated")
    ∧ (i.operation = "display" → o.message = "Payload details displayed")
    ∧ (i.operation = "exploit" → o.message = "Limited payload exploitation initiated")

example : Spec.pre { payloadId := "P123", operation := "receive" } ∧
          Spec.post { payloadId := "P123", operation := "receive" }
                    { success := true, message := "Payload received successfully" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { success := true, message := if x.operation = "receive" then "Payload received successfully"
                                else if x.operation = "process" then "Payload processing initiated"
                                else if x.operation = "display" then "Payload details displayed"
                                else if x.operation = "exploit" then "Limited payload exploitation initiated"
                                else "Unknown operation" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
