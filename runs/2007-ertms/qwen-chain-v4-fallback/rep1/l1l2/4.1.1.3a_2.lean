import ContractForge
open ContractForge

-- 4.1.1.3a#2: It shall be possible to send information on adhesion conditions from trackside.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { conditions := x.conditions }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
