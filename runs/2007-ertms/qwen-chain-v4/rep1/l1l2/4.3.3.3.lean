import ContractForge
open ContractForge

-- 4.3.3.3: When the train is stationary or after a certain time (e.g. the time for "route releasing" of the overlap, the release speed calculation shall be based on the distance to the danger point (if calculated on-board). The condition for this change shall be defined for each target as infrastructure data.

-- L0 spec

structure Input where
  distanceToDangerPoint : Nat
  timeSinceStationary   : Nat
  infrastructureData    : Nat
  deriving DecidableEq, Repr

structure Output where
  releaseSpeed : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.timeSinceStationary = 0 ∨ i.timeSinceStationary ≥ i.infrastructureData
  post := fun i o => (o.releaseSpeed = 0 ↔ i.timeSinceStationary = 0) ∧
                     (o.releaseSpeed ≠ 0 ↔
                      i.timeSinceStationary ≥ i.infrastructureData ∧
                      o.releaseSpeed = i.distanceToDangerPoint)

example : Spec.pre { distanceToDangerPoint := 100, timeSinceStationary := 0,
                     infrastructureData := 60 } ∧
          Spec.post { distanceToDangerPoint := 100, timeSinceStationary := 0,
                      infrastructureData := 60 }
                    { releaseSpeed := 0 } := by
  unfold Spec; decide

example : Spec.pre { distanceToDangerPoint := 100, timeSinceStationary := 120,
                     infrastructureData := 60 } ∧
          Spec.post { distanceToDangerPoint := 100, timeSinceStationary := 120,
                      infrastructureData := 60 }
                    { releaseSpeed := 100 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { releaseSpeed := if x.timeSinceStationary = 0 then 0 else x.distanceToDangerPoint }
