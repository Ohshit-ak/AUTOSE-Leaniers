import ContractForge
open ContractForge

-- 4.1.1.3a#2: It shall be possible to send information on adhesion conditions from trackside.
-- compiles: True · rejects_bad_example: None · checked: True

structure AdhesionCondition where
  frictionCoefficient : Nat
  temperature         : Nat
  deriving DecidableEq, Repr

structure Input where
  conditions : List AdhesionCondition
  deriving DecidableEq, Repr

structure Output where
  conditions : List AdhesionCondition
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.conditions = i.conditions

example : Spec.pre { conditions := [{ frictionCoefficient := 5, temperature := 100 }] } ∧
          Spec.post { conditions := [{ frictionCoefficient := 5, temperature := 100 }] }
                    { conditions := [{ frictionCoefficient := 5, temperature := 100 }] } := by
  unfold Spec; decide
