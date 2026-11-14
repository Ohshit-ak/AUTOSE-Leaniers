import ContractForge
open ContractForge

-- 4.5.9/S1: EIRENE mobile equipment shall be capable of being stored (ie without being operational) at temperatures down to -40°C without any permanent damage.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { stored := decide (x.temperature = 40) }
