import ContractForge
open ContractForge

-- 9.2.1.1: 9.2.1.1 The EIRENE system shall enable users to originate and receive calls by functional number. (M)

-- L0 spec

structure Input where
  functionalNumber : String
  deriving DecidableEq, Repr

structure Output where
  callOriginated : Bool
  callReceived   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber ≠ ""
  post := fun i o => (o.callOriginated = true ↔ i.functionalNumber = "1234567890") ∧
                     (o.callReceived = true ↔ i.functionalNumber = "1234567890")

example : Spec.pre { functionalNumber := "1234567890" } ∧
          Spec.post { functionalNumber := "1234567890" }
                    { callOriginated := true, callReceived := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { callOriginated := decide (x.functionalNumber = "1234567890"), callReceived := decide (x.functionalNumber = "1234567890") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
