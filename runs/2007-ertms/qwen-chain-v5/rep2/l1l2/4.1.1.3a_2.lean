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
  post := fun i o => o.conditions.length = i.conditions.length ∧
                     ∀ j ∈ o.conditions, ∃ k ∈ i.conditions, j.frictionCoefficient = k.frictionCoefficient ∧
                     j.temperature = k.temperature

example : Spec.pre { conditions := [{ frictionCoefficient := 5, temperature := 100 }] } ∧
          Spec.post { conditions := [{ frictionCoefficient := 5, temperature := 100 }] }
                    { conditions := [{ frictionCoefficient := 5, temperature := 100 }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { conditions := x.conditions.filter (fun j => ∃ k ∈ x.conditions, j.frictionCoefficient = k.frictionCoefficient ∧ j.temperature = k.temperature) }
