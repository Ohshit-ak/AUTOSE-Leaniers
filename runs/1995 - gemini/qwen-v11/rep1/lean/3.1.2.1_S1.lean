import ContractForge
open ContractForge

-- 3.1.2.1/S1: Detector data must be acquired and stored in the most effective way technology will allow; effectiveness should be evaluated in terms of cost, space requirements, longevity, and speed.
-- compiles: False · rejects_bad_example: None · checked: False

structure DetectorData where
  data : List String
  cost  : Nat
  space : Nat
  longevity : Nat
  speed : Nat
  deriving DecidableEq, Repr

structure Input where
  technology : String
  deriving DecidableEq, Repr

structure Output where
  data : List String
  cost  : Nat
  space : Nat
  longevity : Nat
  speed : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.data = i.technology :: o.data ∧
                     o.cost = i.cost ∧
                     o.space = i.space ∧
                     o.longevity = i.longevity ∧
                     o.speed = i.speed

example : Spec.pre { technology := "AdvancedTech", cost := 1000, space := 50, longevity := 10, speed := 200 } ∧
          Spec.post { technology := "AdvancedTech", cost := 1000, space := 50, longevity := 10, speed := 200 }
                    { data := ["AdvancedTech"], cost := 1000, space := 50, longevity := 10, speed := 200 } := by
  unfold Spec; decide
