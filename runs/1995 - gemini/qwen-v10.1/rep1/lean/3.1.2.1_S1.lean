import ContractForge
open ContractForge

-- 3.1.2.1/S1: Detector data must be acquired and stored in the most effective way technology will allow; effectiveness should be evaluated in terms of cost, space requirements, longevity, and speed.
-- compiles: True · rejects_bad_example: True · checked: True

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
