import ContractForge
open ContractForge

-- 3.1.5.1.3/S3: When a request to turn on a heating or cooling unit is received, the system shall determine if the request can be honored.

-- L0 spec

structure Input where
  unitId : Nat
  status : String
  deriving DecidableEq, Repr

structure Output where
  canHonor : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.status ∈ ["off", "error"]
  post := fun i o => o.canHonor = true ↔ i.status = "off"

example : Spec.pre { unitId := 1, status := "off" } ∧
          Spec.post { unitId := 1, status := "off" }
                    { canHonor := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { canHonor := decide (x.status = "off") }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
