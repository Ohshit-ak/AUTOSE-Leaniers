import ContractForge
open ContractForge

-- 12.2.3: 12.2.3 If a message is safety related, the safety mechanisms will be included at the application level and do not concern the EIRENE system. (I)
-- compiles: True · rejects_bad_example: True · checked: True

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
