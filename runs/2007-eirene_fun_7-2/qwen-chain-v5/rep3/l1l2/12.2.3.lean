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
  post := fun i o => (o.safetyMechanismsIncluded = true ↔ i.safetyRelated = true ∧ i.message ≠ "emergency stop") ∧
                     (o.safetyMechanismsIncluded = false ↔ i.safetyRelated = false)

example : Spec.pre { message := "test", safetyRelated := true } ∧ Spec.post { message := "test", safetyRelated := true } { safetyMechanismsIncluded := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { safetyMechanismsIncluded := decide (x.safetyRelated = true ∧ x.message ≠ "emergency stop") }
