import ContractForge
open ContractForge

-- 3.1.2.1/S1: Detector data must be acquired and stored in the most effective way technology will allow; effectiveness should be evaluated in terms of cost, space requirements, longevity, and speed.

-- L0 spec

structure DetectorData where
  data : String
  cost  : Nat
  space : Nat
  longevity : Nat
  speed : Nat
  deriving DecidableEq, Repr

structure Technology where
  cost  : Nat
  space : Nat
  longevity : Nat
  speed : Nat
  deriving DecidableEq, Repr

structure Input where
  technology : Technology
  deriving DecidableEq, Repr

structure Output where
  data : String
  cost  : Nat
  space : Nat
  longevity : Nat
  speed : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.cost ≤ i.technology.cost ∧
                     o.space ≤ i.technology.space ∧
                     o.longevity ≥ i.technology.longevity ∧
                     o.speed ≥ i.technology.speed

example : Spec.pre { technology := { cost := 1000, space := 100, longevity := 5, speed := 100 } } ∧
          Spec.post { technology := { cost := 1000, space := 100, longevity := 5, speed := 100 } }
                    { data := "detector data", cost := 1000, space := 100, longevity := 5, speed := 100 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { data := "detector data", cost := x.technology.cost, space := x.technology.space, longevity := x.technology.longevity, speed := x.technology.speed }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
