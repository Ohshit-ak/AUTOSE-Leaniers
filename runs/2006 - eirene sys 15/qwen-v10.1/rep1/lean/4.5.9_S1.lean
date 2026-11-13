import ContractForge
open ContractForge

-- 4.5.9/S1: EIRENE mobile equipment shall be capable of being stored (ie without being operational) at temperatures down to -40°C without any permanent damage.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  temperature : Nat
  deriving DecidableEq, Repr

structure Output where
  stored : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => (o.stored = true ↔ i.temperature < 40) ∧
                     (o.stored = false ↔ i.temperature = 40)

example : Spec.pre { temperature := 40 } ∧
          Spec.post { temperature := 40 } { stored := false } := by
  unfold Spec; decide
