import ContractForge
open ContractForge

-- 3.2.3/S1: The TCS will have the functionality necessary to manage all aspects of payload product handling to include receiving, processing, displaying, and performing limited exploitation.

-- L0 spec

structure Input where
  payloadId : String
  operation : String
  data      : String
  deriving DecidableEq, Repr

structure Output where
  success   : Bool
  message   : String
  payloadId : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.operation ∈ ["receive", "process", "display", "exploit"]
  post := fun i o => (o.success = true ↔
    (i.operation = "receive" → i.data ≠ "" ∧ i.data.length ≤ 1000) ∧
    (i.operation = "process" → i.data ≠ "" ∧ i.data.length ≤ 1000) ∧
    (i.operation = "display" → i.data ≠ "" ∧ i.data.length ≤ 1000) ∧
    (i.operation = "exploit" → i.data ≠ "" ∧ i.data.length ≤ 1000))

example : Spec.pre { payloadId := "P123", operation := "receive", data := "data123" } ∧
          Spec.post { payloadId := "P123", operation := "receive", data := "data123" }
                    { success := true, message := "", payloadId := "P123" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { success := decide ((x.operation = "receive" → x.data ≠ "" ∧ x.data.length ≤ 1000) ∧
    (x.operation = "process" → x.data ≠ "" ∧ x.data.length ≤ 1000) ∧
    (x.operation = "display" → x.data ≠ "" ∧ x.data.length ≤ 1000) ∧
    (x.operation = "exploit" → x.data ≠ "" ∧ x.data.length ≤ 1000)),
    message := "",
    payloadId := x.payloadId }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
