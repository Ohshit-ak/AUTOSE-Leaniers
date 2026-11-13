import ContractForge
open ContractForge

-- 3.1.6.3/S1: This process shall recognize the values for the requested heating or cooling unit and the ON or OFF status that is being requested.

-- L0 spec

structure Input where
  unitId : Nat
  requestedStatus : String
  deriving DecidableEq, Repr

structure Output where
  unitId : Nat
  status : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.requestedStatus = "ON" ∨ i.requestedStatus = "OFF"
  post := fun i o => o.unitId = i.unitId ∧
                     (o.status = "ON" ↔ i.requestedStatus = "ON") ∧
                     (o.status = "OFF" ↔ i.requestedStatus = "OFF")

example : Spec.pre { unitId := 123, requestedStatus := "ON" } ∧
          Spec.post { unitId := 123, requestedStatus := "ON" }
                    { unitId := 123, status := "ON" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { unitId := x.unitId, status := if x.requestedStatus = "ON" then "ON" else "OFF" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
