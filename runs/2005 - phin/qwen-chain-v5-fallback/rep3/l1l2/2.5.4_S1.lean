import ContractForge
open ContractForge

-- 2.5.4/S1: Systems supporting OM should be able to receive, parse and process messages for laboratory test request responses, in accordance with PHIN Laboratory Test Order Response Message Implementation Guide, available at www.cdc.gov/phin.

-- L0 spec

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  parsed   : Option String
  response : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ ""
  post := fun i o => (o.parsed = some "Lab test request response" ↔
    i.message.toList.all Char.isAlpha = true ∧ i.message.length = 30) ∧
                     (o.response = true ↔ o.parsed = some "Lab test request response")

example : Spec.pre { message := "Lab test request response" } ∧ Spec.post { message := "Lab test request response" } { parsed := none, response := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { parsed := if x.message.toList.all Char.isAlpha = true ∧ x.message.length = 30 then some "Lab test request response" else none,
    response := (x.message.toList.all Char.isAlpha = true ∧ x.message.length = 30) = true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
