import ContractForge
open ContractForge

-- 3.2.2: 3.2.2 The level of coverage should be at least 95% of the time over 95% of the designated coverage area for a radio installed in a vehicle with an external antenna. (O)

-- L0 spec

structure Input where
  coverageArea : Nat
  designatedArea : Nat
  time : Nat
  deriving DecidableEq, Repr

structure Output where
  levelOfCoverage : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.coverageArea ∧ 0 < i.designatedArea ∧ 0 < i.time
  post := fun i o => o.levelOfCoverage = (i.coverageArea * i.time) / i.designatedArea ∧
                     o.levelOfCoverage ≥ 95

example : Spec.pre { coverageArea := 95, designatedArea := 95, time := 100 } ∧ Spec.post { coverageArea := 95, designatedArea := 95, time := 100 } { levelOfCoverage := 100 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { levelOfCoverage := max (x.coverageArea * x.time / x.designatedArea) 95 }
