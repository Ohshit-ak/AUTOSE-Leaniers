import ContractForge
open ContractForge

-- 12.2.3: 12.2.3 If a message is safety related, the safety mechanisms will be included at the application level and do not concern the EIRENE system. (I)

-- L0 spec

structure Input where
  message : String
  safetyRelated : Bool
  deriving DecidableEq, Repr

structure Output where
  safetyMechanismsIncluded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.safetyRelated = true ∨ i.safetyRelated = false
  post := fun i o => (o.safetyMechanismsIncluded = true ↔ i.safetyRelated = false) ∧
                     (o.safetyMechanismsIncluded = false ↔ i.safetyRelated = true)

example : Spec.pre { message := "Safety critical update", safetyRelated := true } ∧
          Spec.post { message := "Safety critical update", safetyRelated := true }
                    { safetyMechanismsIncluded := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { safetyMechanismsIncluded := decide (x.safetyRelated = false) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
