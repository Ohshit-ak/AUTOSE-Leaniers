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
  post := fun i o => (o.safetyMechanismsIncluded = true ↔ i.safetyRelated = false) ∧
                     (o.safetyMechanismsIncluded = false ↔ i.safetyRelated = true)

example : Spec.pre { message := "Safety critical update", safetyRelated := true } ∧
          Spec.post { message := "Safety critical update", safetyRelated := true }
                    { safetyMechanismsIncluded := false } := by
  unfold Spec; decide
